CREATE PROCEDURE `sp_ECFProcess_Get`(IN ls_Type varchar(1024),IN ls_Sub_Type varchar(1024),
IN lj_Filters json,IN lj_Classification json, OUT Message varchar(1024))
sp_ECFProcess_Get:BEGIN
Declare Query_Select varchar(6144);
Declare Query_Search varchar(1024);
Declare Query_Search1 varchar(1024);
Declare Query_Group varchar(1024);
Declare Query_Column varchar(1024);
Declare Query_Limit varchar(1024);
declare errno int;
declare msg varchar(1000);
declare i int;
declare li_count int;

#select 45;

if ls_Type ='GET' and ls_Sub_Type='INVOICE_MAKER_SUMMARY' then       
#select 1;
					#select JSON_UNQUOTE(JSON_EXTRACT(lj_Filters,CONCAT('$.employee_gid'))) into @employee_gid;

                    select JSON_UNQUOTE(JSON_EXTRACT(lj_Filters,CONCAT('$.invoiceheader_gid'))) into @invoiceheader_gid;
					select JSON_UNQUOTE(JSON_EXTRACT(lj_Filters,CONCAT('$.invoiceheader_inwarddetailsgid'))) into @invoiceheader_inwarddetailsgid;
					select JSON_UNQUOTE(JSON_EXTRACT(lj_Filters,CONCAT('$.invoiceheader_invoicetype'))) into @invoiceheader_invoicetype;
					select JSON_UNQUOTE(JSON_EXTRACT(lj_Filters,CONCAT('$.employee_gid'))) into @employee_gid;
					select JSON_UNQUOTE(JSON_EXTRACT(lj_Filters,CONCAT('$.supplier_name'))) into @supplier_name;
					select JSON_UNQUOTE(JSON_EXTRACT(lj_Filters,CONCAT('$.invoiceheader_inwarddetailsgid'))) into @invoiceheader_inwarddetailsgid;
					select JSON_UNQUOTE(JSON_EXTRACT(lj_Filters,CONCAT('$.invoiceheader_invoicetype'))) into @invoiceheader_invoicetype;
					select JSON_UNQUOTE(JSON_EXTRACT(lj_Filters,CONCAT('$.invoiceheader_invoiceno'))) into @invoiceheader_invoiceno;
					select JSON_UNQUOTE(JSON_EXTRACT(lj_Filters,CONCAT('$.invoiceheader_otheramount'))) into @invoiceheader_otheramount;
					select JSON_UNQUOTE(JSON_EXTRACT(lj_Filters,CONCAT('$.Page_Index'))) into @Page_Index;
					select JSON_UNQUOTE(JSON_EXTRACT(lj_Filters,CONCAT('$.Page_Size'))) into @Page_Size;
					#select JSON_UNQUOTE(JSON_EXTRACT(lj_Filters,CONCAT('$.invoiceheader_status'))) into @invoiceheader_status;
					select JSON_UNQUOTE(JSON_EXTRACT(lj_Classification,CONCAT('$.Entity_Gid'))) into @Entity_Gid;
					
                    #select @employee_gid;
                    #select @Page_Index,@Page_Size;
					
                    set Query_Select = '';
					#set Query_Search = '';
					
					#select 23,@employee_gid;	
                        /*
					select invoiceheader_status into @invoice_status from ecf_trn_tinvoiceheader
                    where invoiceheader_employeegid= @employee_gid ; 
                
					#select  @invoice_status;
                      
                    if @invoice_status='MAKER' then 
						set Query_Search='';
                    end if;
                  */  
                  
					set Query_Search ='';
                    
                    # select @employee_gid;
                    if @employee_gid > 0 then
                    
					   set Query_Search = concat(Query_Search,' and  emp.employee_gid in (',@employee_gid,') ');
				   
                   elseif @employee_gid=0 then
                        set Query_Search='';
					end if;
                    
                    if @invoiceheader_gid <> '' then	
					   set Query_Search = concat(Query_Search,' and  a.invoiceheader_gid  =',@invoiceheader_gid,' ');
					end if;
                    
                    if @invoiceheader_inwarddetailsgid <> '' then	
					   set Query_Search = concat(Query_Search,' and  a.invoiceheader_inwarddetailsgid  =',@invoiceheader_inwarddetailsgid,' ');
					end if;
                    
                    if @invoiceheader_invoicetype <> '' then	
					   set Query_Search = concat(Query_Search,' and  a.invoiceheader_invoicetype  =''',@invoiceheader_invoicetype,''' ');
					end if;
                    
                    if @supplier_name <> '' then	
					   set Query_Search = concat(Query_Search,' and  b.supplier_name like ''','%',@supplier_name,'%',''' ');
					end if;
                    
                   # select invoiceheader_invoiceno;
                    if @invoiceheader_invoiceno <> '' then	
					   set Query_Search = concat(Query_Search,' and  a.invoiceheader_invoiceno = ',@invoiceheader_invoiceno,' ');
					end if;
                    
                    if @invoiceheader_otheramount <> '' then	
					   set Query_Search = concat(Query_Search,' and  a.invoiceheader_otheramount = ',@invoiceheader_otheramount,' ');
					end if;
                   
                    
                 #   select Query_Search;
                    
                    
                    set @total_size= @Page_Index*@Page_Size;    
					 # select  @total_size,  @Page_Index,@Page_Size;
					set Query_Limit='';
						#select @Page_Index,@Page_Size;				
						if @Page_Index <> '' and @Page_Index is not null and @Page_Size <> '' and @Page_Size is not null  then 
					  
										 set @total_size= @Page_Index*@Page_Size;
										 set @Page_Size=@Page_Size;
										 set Query_Limit = concat(Query_Limit,' LIMIT ',@Page_Size,' OFFSET ',@total_size,'  ');
						
						else
										#select 1;
										set @Page_Index=2,@Page_Size=5;
										#select @Page_Index,@Page_Size;
										set @total_size= @Page_Index*@Page_Size;
										#select @total_size;
										set Query_Limit = concat(Query_Limit,' LIMIT ',@Page_Size,' OFFSET ',@total_size,'  ');
						End if;

                     set Query_Column='';

                    if @Page_Index=0 and @Page_Size=10 then
                        set Query_Column = (',@Total_Row as Total_Row');
					else
						set Query_Column='';
                    end if;

                    #select Query_Column;


					#select Query_Limit;
                    set Query_Select='';
					set Query_Select = Concat('select a.invoiceheader_employeegid,a.invoiceheader_ppx,a.invoiceheader_gid,invoiceheader_inwarddetailsgid,b.supplier_gid,a.invoiceheader_crno,
						a.invoiceheader_invoicetype,b.supplier_name,a.invoiceheader_invoiceno,a.invoiceheader_invoicedate as invoiceheader_invoicedate_full,
						date_format(a.invoiceheader_invoicedate,''%d-%m-%Y'') as invoiceheader_invoicedate ,a.invoiceheader_otheramount,
						a.invoiceheader_amount,a.invoiceheader_status,supplier_gstno as gst_no,emp.employee_name,emp.employee_gid,
						a.invoiceheader_gst as IS_GST,a.invoiceheader_remarks   ',Query_Column,'
						from ecf_trn_tinvoiceheader as a
						left join gal_mst_tsupplier as b on b.supplier_gid = a.invoiceheader_suppliergid and
									 a.invoiceheader_isactive = ''Y'' and a.invoiceheader_isremoved = ''N'' and
                                     b.supplier_isactive=''Y'' and b.supplier_isremoved=''N''
						left join gal_mst_temployee as emp on emp.employee_gid = a.invoiceheader_employeegid and
									emp.employee_isactive=''Y'' and emp.employee_isremoved=''N''
						where  a.entity_gid = ',@Entity_Gid,'
                        ' ,Query_Search,'
						group by  a.invoiceheader_gid
                        order by a.invoiceheader_gid desc
                      	');
                   #select Query_Select;


                #  select @Page_Index,@Page_Size;
                  if @Page_Index=0 and @Page_Size=10 then
                  # select 555;
                        set @Query_Count = '';
                        set @Query_Count = concat('select count(A.invoiceheader_employeegid) into @Total_Row from (',Query_Select,') A ');
                          	PREPARE stmt FROM @Query_Count;
								EXECUTE stmt;
							DEALLOCATE PREPARE stmt;

                  end if;
               # select @Query_Count;
                    # select @Query_Count;
				    # select Query_Limit;
					 set @p = concat(Query_Select,Query_Limit)	;

						#select  @p; ## Remove it
						PREPARE stmt FROM @p;
						EXECUTE stmt;
						Select found_rows() into li_count;
						DEALLOCATE PREPARE stmt;

							if li_count = 0 then
								set Message = 'NOT_FOUND';
							else
								set Message = 'FOUND';
							end if;

end if;

if ls_Type ='GET' and ls_Sub_Type='INVOICE_APPROVAL' then

		select JSON_UNQUOTE(JSON_EXTRACT(lj_Filters,CONCAT('$.employee_gid'))) into @employee_gid;
		select JSON_UNQUOTE(JSON_EXTRACT(lj_Filters,CONCAT('$.invoiceheader_ppx'))) into @invoiceheader_ppx;
		select JSON_UNQUOTE(JSON_EXTRACT(lj_Filters,CONCAT('$.invoiceheader_inwarddetailsgid'))) into @invoiceheader_inwarddetailsgid;
		select JSON_UNQUOTE(JSON_EXTRACT(lj_Filters,CONCAT('$.invoiceheader_invoicetype'))) into @invoiceheader_invoicetype;
		select JSON_UNQUOTE(JSON_EXTRACT(lj_Filters,CONCAT('$.invoiceheader_invoiceno'))) into @invoiceheader_invoiceno;
		select JSON_UNQUOTE(JSON_EXTRACT(lj_Filters,CONCAT('$.supplier_name'))) into @supplier_name;
		select JSON_UNQUOTE(JSON_EXTRACT(lj_Filters,CONCAT('$.invoiceheader_otheramount'))) into @invoiceheader_otheramount;
		select JSON_UNQUOTE(JSON_EXTRACT(lj_Filters,CONCAT('$.invoiceheader_gst'))) into @invoiceheader_gst;
		select JSON_UNQUOTE(JSON_EXTRACT(lj_Filters,CONCAT('$.invoiceheader_status'))) into @invoiceheader_status;
		select JSON_UNQUOTE(JSON_EXTRACT(lj_Filters,CONCAT('$.supplier_gstno'))) into @supplier_gstno;
		select JSON_UNQUOTE(JSON_EXTRACT(lj_Filters,CONCAT('$.employee_name'))) into @employee_name;
		select JSON_UNQUOTE(JSON_EXTRACT(lj_Filters,CONCAT('$.invoiceheader_gst'))) into @invoiceheader_gst;
		select JSON_UNQUOTE(JSON_EXTRACT(lj_Filters,CONCAT('$.Page_Index'))) into @Page_Index;
		select JSON_UNQUOTE(JSON_EXTRACT(lj_Filters,CONCAT('$.Page_Size'))) into @Page_Size;
		select JSON_UNQUOTE(JSON_EXTRACT(lj_Classification,CONCAT('$.Entity_Gid'))) into @Entity_Gid;
        #select @employee_gid,@Entity_Gid;

        set Query_Search='';
       # select @invoiceheader_inwarddetailsgid;

         if @invoiceheader_ppx <> '' then
		   set Query_Search = concat(Query_Search,' and  a.invoiceheader_ppx  like ''','%',@invoiceheader_ppx,'%',''' ');
		 end if;

         if @invoiceheader_inwarddetailsgid <> '' then
		   set Query_Search = concat(Query_Search,' and  a.invoiceheader_inwarddetailsgid  =',@invoiceheader_inwarddetailsgid,' ');
		 end if;

         if @invoiceheader_invoicetype <> '' then
		   set Query_Search = concat(Query_Search,' and  a.invoiceheader_invoicetype  =''',@invoiceheader_invoicetype,''' ');
		 end if;

         if @supplier_name <> '' then
		   set Query_Search = concat(Query_Search,' and  b.supplier_name  like ''','%',@supplier_name,'%','''  ');
		 end if;

         if @invoiceheader_invoiceno <> '' then
		   set Query_Search = concat(Query_Search,' and  a.invoiceheader_invoiceno  =',@invoiceheader_invoiceno,' ');
		 end if;


         if @invoiceheader_otheramount <> '' then
		   set Query_Search = concat(Query_Search,' and  a.invoiceheader_otheramount  =''',@invoiceheader_otheramount,''' ');
		 end if;

         if @invoiceheader_status <> '' then
		   set Query_Search = concat(Query_Search,' and  a.invoiceheader_status  like ''','%',@invoiceheader_status,'%',''' ');
		 end if;

         if @supplier_gstno <> '' then
		   set Query_Search = concat(Query_Search,' and b.supplier_gstno  = ''',@supplier_gstno,''' ');
		 end if;

        if @employee_name <> '' then
		   set Query_Search = concat(Query_Search,' and  emp.employee_name  like ''','%',@employee_name,'%','''  ');
		 end if;

         if @invoiceheader_gst <> '' then
		   set Query_Search = concat(Query_Search,' and  a.invoiceheader_gst  like ''','%',@invoiceheader_gst,'%','''  ');
		 end if;

      #select Query_Search;

         set @total_size= @Page_Index*@Page_Size;
		  #select  @total_size,  @Page_Index,@Page_Size;
		 set Query_Limit='';
			#select @Page_Index,@Page_Size;
			if @Page_Index <> '' and @Page_Index is not null and @Page_Size <> '' and @Page_Size is not null  then

							 set @total_size= @Page_Index*@Page_Size;
							 #set @Page_Size=@Page_Size;
							 set Query_Limit = concat(Query_Limit,' LIMIT ',@Page_Size,' OFFSET ',@total_size,'  ');

			else
							#select 1;
							set @Page_Index=2,@Page_Size=5;
							#select @Page_Index,@Page_Size;
							set @total_size= @Page_Index*@Page_Size;
							#select @total_size;
							set Query_Limit = concat(Query_Limit,' LIMIT ',@Page_Size,' OFFSET ',@total_size,'  ');
			End if;

             set Query_Column='';

             if @Page_Index=0 and @Page_Size=10 then
				set Query_Column = (', @Total_Row as Total_Row');
             else
					set Query_Column='';
			 end if;

      #select Query_Limit,Query_Column,@employee_gid,@Entity_Gid;
        set Query_Select ='';
        set Query_Select = Concat('select a.invoiceheader_employeegid,a.invoiceheader_ppx,a.invoiceheader_gid,invoiceheader_inwarddetailsgid,b.supplier_gid,a.invoiceheader_crno,
						a.invoiceheader_invoicetype,b.supplier_name,a.invoiceheader_invoiceno,a.invoiceheader_invoicedate as invoiceheader_invoicedate_full,
						date_format(a.invoiceheader_invoicedate,''%d-%m-%Y'') as invoiceheader_invoicedate ,a.invoiceheader_otheramount,
						a.invoiceheader_amount,a.invoiceheader_status,supplier_gstno as gst_no,emp.employee_name,emp.employee_gid,
						a.invoiceheader_gst as IS_GST,a.invoiceheader_remarks   ',Query_Column,' from   (select tran_gid, tran_ref_gid, tran_reftable_gid, tran_status, tran_from,
                        tran_fromdate, tran_totype, tran_to, tran_by, tran_date, tran_remarks

                        from gal_trn_ttran where tran_ref_gid = 53 and tran_totype = ''I'')  as tran
						inner join ecf_trn_tinvoiceheader as a on a.invoiceheader_gid = tran_reftable_gid
						left join gal_mst_tsupplier as b on b.supplier_gid = a.invoiceheader_suppliergid and
									 a.invoiceheader_isactive = ''Y'' and a.invoiceheader_isremoved = ''N'' and
                                     b.supplier_isactive=''Y'' and b.supplier_isremoved=''N''
						left join gal_mst_temployee as emp on emp.employee_gid = a.invoiceheader_employeegid and
									emp.employee_isactive=''Y'' and emp.employee_isremoved=''N''
						where  a.entity_gid in (',@Entity_Gid,')   and tran_to = ',@employee_gid,'  ',Query_Search,'
						group by a.invoiceheader_gid
						order by a.invoiceheader_gid desc   ');
         #select Query_Select;

          if @Page_Index=0 and @Page_Size=10 then
				#select 555;
				set @Query_Count = '';
				set @Query_Count = concat('select count(A.invoiceheader_employeegid) into @Total_Row from (',Query_Select,') A ');
                #select @Total_Row;
					PREPARE stmt FROM @Query_Count;
						EXECUTE stmt;
					DEALLOCATE PREPARE stmt;
		  #select @Query_Count;
          end if;




        set @p = concat(Query_Select,Query_Limit);
       # select @p;
		#select Query_Select; ### Remove It.
		PREPARE stmt FROM @p;
		EXECUTE stmt;
		Select found_rows() into li_count;
		DEALLOCATE PREPARE stmt;


			if li_count > 0 then
				set Message = 'FOUND';
			else
				set Message = 'NOT_FOUND';
			end if;


end if;


if ls_Type ='GET' and ls_Sub_Type='INVOICE_DETAILS_EDIT' then

		select JSON_UNQUOTE(JSON_EXTRACT(lj_Filters,CONCAT('$.InvoiceHeader_Gid'))) into @InvoiceHeader_Gid;
		select JSON_UNQUOTE(JSON_EXTRACT(lj_Classification,CONCAT('$.Entity_Gid'))) into @Entity_Gid;

		#SELECT @InvoiceHeader_Gid,@Entity_Gid;
		set Query_Select ='';
        set Query_Select = Concat('select invoiceheader_gid,
									invoicedetails_item,
                                    invoicedetails_desc,
											invoicedetails_hsncode,invoicedetails_unitprice,
											invoicedetails_qty,invoicedetails_amount,invoicedetails_discount,
                                            invoicedetails_igst,invoicedetails_cgst,
											invoicedetails_taxamt,invoicedetails_totalamt
									from ecf_trn_tinvoiceheader as a
									inner join ecf_trn_tinvoicedetails as b on b.invoicedetails_invoiceheadergid = a.invoiceheader_gid and
																			  a.invoiceheader_isactive = ''Y'' and a.invoiceheader_isremoved = ''N'' and
																			  b.invoicedetails_isactive = ''Y''  and b.invoicedetails_isremoved = ''N''
                                    where a.invoiceheader_gid =',@InvoiceHeader_Gid,'  and a.entity_gid in (',@Entity_Gid,')  ');
        set @p = Query_Select;
		#select Query_Select; ### Remove It.
		PREPARE stmt FROM @p;
		EXECUTE stmt;
		Select found_rows() into li_count;
		DEALLOCATE PREPARE stmt;


			if li_count > 0 then
				set Message = 'FOUND';
			else
				set Message = 'NOT_FOUND';
			end if;


        set Query_Select ='';
        set Query_Select = Concat('
									select invoiceheader_gid,debit_gid,debit_categorygid,debit_glno,debit_amount,ccbsdtl_code,ccbsdtl_percent,
									ccbsdtl_glno,ccbsdtl_amount,tcc_name,tbs_name,category_name,category_glno,subcategory_name,subcategory_glno
												from ecf_trn_tinvoiceheader as a
												inner join ecf_trn_tinvoicedetails as b on b.invoicedetails_invoiceheadergid = a.invoiceheader_gid and
															a.invoiceheader_isactive = ''Y'' and a.invoiceheader_isremoved = ''N'' and
															b.invoicedetails_isactive = ''Y''  and b.invoicedetails_isremoved = ''N''
												inner join ecf_trn_tdebit c on a.invoiceheader_gid=c.debit_invoiceheadergid and
															c.debit_isactive=''Y'' and c.debit_isremoved=''N''
												inner join ecf_trn_tccbsdtl d on c.debit_gid=d.ccbsdtl_ecfdebitgid and
															d.ccbsdtl_isactive=''Y'' and d.ccbsdtl_isremoved=''N''
												inner join ap_mst_tcc e on d.ccbsdtl_cc=e.tcc_gid and
															e.tcc_isactive=''Y'' and e.tcc_isremoved=''N''
												inner join ap_mst_tbs f on d.ccbsdtl_bs=f.tbs_gid and
															f.tbs_isactive=''Y'' and f.tbs_isremoved=''N''
												inner join ap_mst_tcategory cat on c.debit_categorygid=cat.category_gid and
															cat.category_isactive=''Y'' and cat.category_isremoved=''N''
												inner join ap_mst_tsubcategory sub on c.debit_subcategorygid=sub.subcategory_gid and
															sub.subcategory_isactive=''Y'' and sub.subcategory_isremoved=''N''
												where a.invoiceheader_gid =',@InvoiceHeader_Gid,'  and a.entity_gid in (',@Entity_Gid,')
                                                group by debit_gid');
        set @p = Query_Select;
		#select Query_Select; ### Remove It.
		PREPARE stmt FROM @p;
		EXECUTE stmt;
		Select found_rows() into li_count;
		DEALLOCATE PREPARE stmt;


			if li_count > 0 then
				set Message = 'FOUND';
			else
				set Message = 'NOT_FOUND';
			end if;


        set Query_Select ='';
        set Query_Select = Concat('
										select invoiceheader_gid,
											credit_paymodegid,credit_glno,credit_refno,credit_suppliertaxgid,
                                            credit_suppliertaxtrate,credit_tdsexcempted,credit_amount,
											ppxdetails_creditgid,ppxdetails_amount,ppxdetails_adjusted,ppxdetails_balance,
											bankbranch_name,bankbranch_ifsccode,bankbranch_microcode,bankbranch_address_gid,
                                            bankdetails_reftable_code,bankdetails_paymode_gid,bankdetails_acno,
                                            bankdetails_beneficiaryname,Paymode_name
										from ecf_trn_tinvoiceheader a
										inner join ecf_trn_tcredit b on a.invoiceheader_gid=b.credit_invoiceheadergid and
													a.invoiceheader_isactive=''Y'' and a.invoiceheader_isremoved=''N'' and
													b.credit_isactive=''Y'' and b.credit_isremoved=''N''
										left join ap_trn_tppxdetails c on b.credit_gid=c.ppxdetails_creditgid and
													c.ppxdetails_isactive=''Y'' and c.ppxdetails_isremoved=''N''
										left join gal_mst_tbankbranch d on b.credit_bankgid=d.bankbranch_gid and
													d.bankbranch_isactive=''Y'' and d.bankbranch_isremoved=''N''
										inner join gal_mst_tref as z on z.ref_name = ''SUPPLIER_PAYMENT''  and
												 z.ref_active=''Y'' and z.ref_isremoved=''N''
										left join gal_trn_tbankdetails as f on f.bankdetails_reftable_gid = a.invoiceheader_suppliergid and
												f.bankdetails_isactive=''Y'' and f.bankdetails_isremoved=''N''
										left join gal_mst_tpaymode as g on g.paymode_gid = b.credit_paymodegid and
												g.paymode_isactive = ''Y'' and g.paymode_isremoved = ''N''
												where a.invoiceheader_gid =',@InvoiceHeader_Gid,'  and a.entity_gid in (',@Entity_Gid,')
                                                group by credit_gid');
        set @p = Query_Select;
		#select Query_Select; ### Remove It.
		PREPARE stmt FROM @p;
		EXECUTE stmt;
		Select found_rows() into li_count;
		DEALLOCATE PREPARE stmt;


			if li_count > 0 then
				set Message = 'FOUND';
			else
				set Message = 'NOT_FOUND';
			end if;



end if;



if ls_Type ='GET' and ls_Sub_Type='BARCODE_GENERATION' then

		select JSON_UNQUOTE(JSON_EXTRACT(lj_Filters,CONCAT('$.InvoiceHeader_Gid'))) into @InvoiceHeader_Gid;
		select JSON_UNQUOTE(JSON_EXTRACT(lj_Classification,CONCAT('$.Entity_Gid'))) into @Entity_Gid;

		#SELECT @InvoiceHeader_Gid,@Entity_Gid;
		set Query_Select ='';
        set Query_Select = Concat('select branch_code,invoiceheader_gid,invoiceheader_inwarddetailsgid,invoiceheader_ecfheadergid,invoiceheader_crno,
											invoiceheader_invoicetype,invoiceheader_employeegid,invoiceheader_suppliergid,invoiceheader_supplierstategid,
                                            date_format(invoiceheader_invoicedate,''%Y-%b-%d'') as invoiceheader_invoicedate,invoiceheader_remarks,
											invoiceheader_invoiceno,invoiceheader_otheramount,invoiceheader_amount,invoiceheader_status,emp.employee_name,
                                            emp.employee_code
											from ecf_trn_tinvoiceheader as a
                                            left join gal_mst_temployee as emp on emp.employee_gid = a.invoiceheader_employeegid and
											a.invoiceheader_isactive = ''Y'' and a.invoiceheader_isremoved = ''N'' and
                                            emp.employee_isactive=''Y'' and emp.employee_isremoved=''N''
                                            left join gal_mst_tbranch as br on br.branch_gid = a.invoiceheader_branchgid
											where a.invoiceheader_gid =',@InvoiceHeader_Gid,'  and a.entity_gid in (',@Entity_Gid,') ');
        set @p = Query_Select;
		#select Query_Select; ### Remove It.
		PREPARE stmt FROM @p;
		EXECUTE stmt;
		Select found_rows() into li_count;
		DEALLOCATE PREPARE stmt;


			if li_count > 0 then
				set Message = 'FOUND';
			else
				set Message = 'NOT_FOUND';
			end if;

        set Query_Select ='';
        set Query_Select = Concat('select invoiceheader_gid,invoiceheader_invoiceno,
									date_format( invoiceheader_invoicedate,''%Y-%m-%d'') as invoiceheader_invoicedate,
									invoicedetails_item,invoicedetails_desc,
											invoicedetails_hsncode,invoicedetails_unitprice,
											invoicedetails_qty,invoicedetails_amount,invoicedetails_discount,
                                            invoicedetails_igst,invoicedetails_cgst,
											invoicedetails_taxamt,invoicedetails_totalamt,ifnull(sup.Supplier_code,''-''),ifnull(sup.supplier_name,''-''),
                                            ifnull(bankbranch_code,''-'')
									from ecf_trn_tinvoiceheader as a
									inner join ecf_trn_tinvoicedetails as b on b.invoicedetails_invoiceheadergid = a.invoiceheader_gid and
																			  a.invoiceheader_isactive = ''Y'' and a.invoiceheader_isremoved = ''N'' and
																			  b.invoicedetails_isactive = ''Y''  and b.invoicedetails_isremoved = ''N''
								    left join gal_mst_tsupplier as sup on sup.supplier_gid = a.invoiceheader_suppliergid and
																	sup.supplier_isactive=''Y'' and sup.supplier_isremoved=''N''
                                    inner join gal_mst_tbankbranch d on a.invoiceheader_branchgid=d.bankbranch_gid and
													d.bankbranch_isactive=''Y'' and d.bankbranch_isremoved=''N''
                                    where a.invoiceheader_gid =',@InvoiceHeader_Gid,'  and a.entity_gid in (',@Entity_Gid,')  ');
        set @p = Query_Select;
		#select Query_Select; ### Remove It.
		PREPARE stmt FROM @p;
		EXECUTE stmt;
		Select found_rows() into li_count;
		DEALLOCATE PREPARE stmt;


			if li_count > 0 then
				set Message = 'FOUND';
			else
				set Message = 'NOT_FOUND';
			end if;


        set Query_Select ='';
        set Query_Select = Concat('
									select invoiceheader_gid,invoicedetails_item,invoicedetails_desc,debit_gid,debit_categorygid,debit_glno,debit_amount,ccbsdtl_code,ccbsdtl_percent,
									ccbsdtl_glno,ccbsdtl_amount,tcc_name,tbs_name,category_name,category_glno,subcategory_name,subcategory_glno
												from ecf_trn_tinvoiceheader as a
												inner join ecf_trn_tinvoicedetails as b on b.invoicedetails_invoiceheadergid = a.invoiceheader_gid and
															a.invoiceheader_isactive = ''Y'' and a.invoiceheader_isremoved = ''N'' and
															b.invoicedetails_isactive = ''Y''  and b.invoicedetails_isremoved = ''N''
												inner join ecf_trn_tdebit c on a.invoiceheader_gid=c.debit_invoiceheadergid and
															c.debit_isactive=''Y'' and c.debit_isremoved=''N''
												inner join ecf_trn_tccbsdtl d on c.debit_gid=d.ccbsdtl_ecfdebitgid and
															d.ccbsdtl_isactive=''Y'' and d.ccbsdtl_isremoved=''N''
												inner join ap_mst_tcc e on d.ccbsdtl_cc=e.tcc_gid and
															e.tcc_isactive=''Y'' and e.tcc_isremoved=''N''
												inner join ap_mst_tbs f on d.ccbsdtl_bs=f.tbs_gid and
															f.tbs_isactive=''Y'' and f.tbs_isremoved=''N''
												inner join ap_mst_tcategory cat on c.debit_categorygid=cat.category_gid and
															cat.category_isactive=''Y'' and cat.category_isremoved=''N''
												inner join ap_mst_tsubcategory sub on c.debit_subcategorygid=sub.subcategory_gid and
															sub.subcategory_isactive=''Y'' and sub.subcategory_isremoved=''N''
												where a.invoiceheader_gid =',@InvoiceHeader_Gid,'  and a.entity_gid in (',@Entity_Gid,')
                                                group by debit_gid');
        set @p = Query_Select;
		#select Query_Select; ### Remove It.
		PREPARE stmt FROM @p;
		EXECUTE stmt;
		Select found_rows() into li_count;
		DEALLOCATE PREPARE stmt;


			if li_count > 0 then
				set Message = 'FOUND';
			else
				set Message = 'NOT_FOUND';
			end if;


        set Query_Select ='';
        set Query_Select = Concat('
										select invoiceheader_gid,
											credit_paymodegid,credit_glno,credit_refno,credit_suppliertaxgid,
                                            credit_suppliertaxtrate,credit_tdsexcempted,credit_amount,
											ppxdetails_creditgid,ppxdetails_amount,ppxdetails_adjusted,ppxdetails_balance,
											bankbranch_name,bankbranch_ifsccode,bankbranch_microcode,bankbranch_address_gid,
                                            bankdetails_reftable_code,bankdetails_paymode_gid,bankdetails_acno,
                                            bankdetails_beneficiaryname,Paymode_name
										from ecf_trn_tinvoiceheader a
										inner join ecf_trn_tcredit b on a.invoiceheader_gid=b.credit_invoiceheadergid and
													a.invoiceheader_isactive=''Y'' and a.invoiceheader_isremoved=''N'' and
													b.credit_isactive=''Y'' and b.credit_isremoved=''N''
										left join ap_trn_tppxdetails c on b.credit_gid=c.ppxdetails_creditgid and
													c.ppxdetails_isactive=''Y'' and c.ppxdetails_isremoved=''N''
										left join gal_mst_tbankbranch d on b.credit_bankgid=d.bankbranch_gid and
													d.bankbranch_isactive=''Y'' and d.bankbranch_isremoved=''N''
										inner join gal_mst_tref as z on z.ref_name = ''SUPPLIER_PAYMENT''  and
												 z.ref_active=''Y'' and z.ref_isremoved=''N''
										left join gal_trn_tbankdetails as f on f.bankdetails_reftable_gid = a.invoiceheader_suppliergid and
												f.bankdetails_isactive=''Y'' and f.bankdetails_isremoved=''N''
										left join gal_mst_tpaymode as g on g.paymode_gid = b.credit_paymodegid and
												g.paymode_isactive = ''Y'' and g.paymode_isremoved = ''N''
												where a.invoiceheader_gid =',@InvoiceHeader_Gid,'  and a.entity_gid in (',@Entity_Gid,')
                                                group by credit_gid');
        set @p = Query_Select;
		#select Query_Select; ### Remove It.
		PREPARE stmt FROM @p;
		EXECUTE stmt;
		Select found_rows() into li_count;
		DEALLOCATE PREPARE stmt;


			if li_count > 0 then
				set Message = 'FOUND';
			else
				set Message = 'NOT_FOUND';
			end if;

end if;

if ls_Type ='GET' and ls_Sub_Type='INVOICE_PAYMENT_DETAIL' then

		select JSON_UNQUOTE(JSON_EXTRACT(lj_Filters,CONCAT('$.ECF_InvoiceHeader_Gid'))) into @ECF_InvoiceHeader_Gid;
		select JSON_UNQUOTE(JSON_EXTRACT(lj_Filters,CONCAT('$.AP_InvoiceHeader_Gid'))) into @AP_InvoiceHeader_Gid;
		select JSON_UNQUOTE(JSON_EXTRACT(lj_Classification,CONCAT('$.Entity_Gid'))) into @Entity_Gid;

		#SELECT @InvoiceHeader_Gid,@Entity_Gid;

        set Query_Search='';

        if @AP_InvoiceHeader_Gid <> '' then
		   set Query_Search = concat(Query_Search,' and  inv.invoiceheader_gid  =',@AP_InvoiceHeader_Gid,'  ');
		end if;

        if @ECF_InvoiceHeader_Gid <> '' then
		   set Query_Search = concat(Query_Search,' and  ecf.invoiceheader_gid  =',@ECF_InvoiceHeader_Gid,'  ');
		end if;



		set Query_Select ='';
        set Query_Select = Concat('
									select ecf.invoiceheader_crno,ecf.invoiceheader_invoicetype,ecf.invoiceheader_amount,ap.invoiceheader_invoicetype,a.paymentheader_pvno,
											a.paymentheader_amount,a.paymentheader_paymode,a.paymentheader_bankdetailsgid,a.paymentheader_beneficiaryname,a.paymentheader_status,
											a.paymentheader_remarks,b.paymentdetails_amount,c.supplier_name,c.supplier_branchname,emp.employee_name
									from ecf_trn_tinvoiceheader ecf
									inner join ap_trn_tinvoiceheader ap on  ecf.invoiceheader_crno = ap.invoiceheader_crno and
																			ecf.invoiceheader_isactive=''Y'' and ecf.invoiceheader_isremoved=''N'' and
																			ap.invoiceheader_isactive=''Y'' and ap.invoiceheader_isremoved=''N''
									left join  ap_trn_tpaymentdetails b on b.paymentdetails_paymentheadergid = ap.invoiceheader_gid and
																			b.paymentdetails_isactive=''Y'' and b.paymentdetails_isremoved=''N''
									left join ap_trn_tpaymentheader a on b.paymentdetails_paymentheadergid=a.paymentheader_gid and
																			a.paymentheader_isactive=''Y'' and a.paymentheader_isremoved=''N''
									left join gal_mst_tref as ref on ref.ref_gid = a.paymentheader_refgid and ref.ref_name = ''SUPPLIER_PAYMENT'' and
																			ref.ref_active=''Y'' and ref.ref_isremoved=''N''
									left join gal_mst_tsupplier as c on c.supplier_gid = a.paymentheader_reftablegid and
																			c.supplier_isactive=''N'' and c.supplier_isremoved=''N''
									left join gal_mst_temployee as emp on a.paymentheader_reftablegid=emp.employee_gid  and ref.ref_name = ''EMPLOYEE_PAYMENT'' and
																		emp.
									where  a.entity_gid in (',@Entity_Gid,')  ',Query_Search,'   ');
        set @p = Query_Select;
		#select Query_Select; ### Remove It.
		PREPARE stmt FROM @p;
		EXECUTE stmt;
		Select found_rows() into li_count;
		DEALLOCATE PREPARE stmt;


			if li_count > 0 then
				set Message = 'FOUND';
			else
				set Message = 'NOT_FOUND';
			end if;

end if;


END