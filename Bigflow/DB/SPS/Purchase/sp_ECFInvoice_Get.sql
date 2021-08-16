
CREATE DEFINER=`developer`@`%` PROCEDURE `sp_ECFInvoice_Get`(In `Action` varchar(64),In `ls_ECF_Number` varchar(64),
in `li_Supplier_gid` int,in `li_InvoiceHeader_gid` int ,in `li_InwardDetails_gid` int ,in `ls_invoiceheader_status` varchar(64),
In `li_Entity_State_gid`int,IN `li_entity_gid` int,out `Message` varchar(1024))
sp_ECFInvoice_Get:BEGIN
# Ramesh 2018-May-16
# Action :
#  INVOICE_MAKER, == Show and GET the Invoic Details.
#  INVOICE_MAKER_SUMMARY  == With Stategid== Used to Fll Header data.
#  INVOICE_DETAILS_EDIT, ==  For Checker and Approver Scnerio. based on one Gid
#  INVOICE_PAYMENT

Declare Query_Select varchar(5000);
Declare Query_Search varchar(2000);
Declare Query_Group varchar(1000);
Declare li_count int;
set Query_Select = '';
set Query_Search = '';
#SET GLOBAL group_concat_max_len = 1000000;
SET SESSION group_concat_max_len=4294967295;
if Action = 'INVOICE_MAKER' then ## Not Sure Where it used. and Show and GET the Invoic Details.
		if li_InwardDetails_gid = 0 then
			set Message = 'Inward Details Gid Is Needed.';
            leave sp_ECFInvoice_Get;
        End if;
		set Query_Search = concat(' and invoiceheader_inwarddetailsgid =',li_InwardDetails_gid,' ');

          if ls_invoiceheader_status <> '' then
			set Query_Search = concat(' and  invoiceheader_status = ''',ls_invoiceheader_status,'''');
		 End if;

	set Query_Select = Concat('select a.invoiceheader_gid,invoiceheader_inwarddetailsgid,emp.employee_name,emp.employee_gid,b.supplier_gid,a.invoiceheader_crno,
		a.invoiceheader_invoicetype,b.supplier_name,a.invoiceheader_invoiceno,
        date_format(a.invoiceheader_invoicedate,''%d-%b-%y'') as invoiceheader_invoicedate,
		a.invoiceheader_amount,a.invoiceheader_status
		from ap_trn_tinvoiceheader as a
		left join gal_mst_tsupplier as b on b.supplier_gid = a.invoiceheader_suppliergid
		left join gal_mst_temployee as emp on emp.employee_gid = a.invoiceheader_employeegid
		where a.invoiceheader_isactive = ''Y'' and a.invoiceheader_isremoved = ''N''
        and a.entity_gid = ',li_entity_gid,'
        ' ,Query_Search,'
					');

		set @p = Query_Select;
		#select Query_Select;
		PREPARE stmt FROM @p;
		EXECUTE stmt;
		Select found_rows() into li_count;
		DEALLOCATE PREPARE stmt;

		if li_count = 0 then
			set Message = 'NOT_FOUND';
		else
			set Message = 'FOUND';
		end if;
elseif Action = 'INVOICE_MAKER_SUMMARY' then
	set Query_Select = '';
    set Query_Search = '';

		if li_Entity_State_gid = 0 then
			set Message = 'Organisation State Gid Is Needed.';
            leave sp_ECFInvoice_Get;
        End if;

	   if ls_invoiceheader_status <> '' then
					set @ls_invoiceheader_status_Final = '';
				   WHILE ls_invoiceheader_status != '' DO  ### Loop a String of Comma or array
										SET @ls_invoiceheader_status = SUBSTRING_INDEX(ls_invoiceheader_status, ',', 1);
										set @ls_invoiceheader_status = concat('',@ls_invoiceheader_status,'');
							IF LOCATE(',', ls_invoiceheader_status) > 0 THEN
												SET ls_invoiceheader_status = SUBSTRING(ls_invoiceheader_status, LOCATE(',', ls_invoiceheader_status) + 1);
							ELSE
												SET ls_invoiceheader_status = '';
							END IF;

                            if @ls_invoiceheader_status_Final = '' then
								set @ls_invoiceheader_status_Final = @ls_invoiceheader_status;
							else
									  set @ls_invoiceheader_status_Final = concat(@ls_invoiceheader_status_Final,''',''',@ls_invoiceheader_status);
                            End if;



					END WHILE;


			set Query_Search = concat(' and  invoiceheader_status in ( ''',@ls_invoiceheader_status_Final,''') ');
		End if;

       if li_InvoiceHeader_gid <> 0 then
			set Query_Search = concat(Query_Search,' and invoiceheader_gid = ',li_InvoiceHeader_gid,' ');
       End if;

	set Query_Select = Concat('select a.invoiceheader_employeegid,a.invoiceheader_gid,invoiceheader_inwarddetailsgid,b.supplier_gid,a.invoiceheader_crno,
		a.invoiceheader_invoicetype,b.supplier_name,a.invoiceheader_invoiceno,a.invoiceheader_invoicedate as invoiceheader_invoicedate_full,
        date_format(a.invoiceheader_invoicedate,''%d-%m-%Y'') as invoiceheader_invoicedate ,a.invoiceheader_otheramount,
		a.invoiceheader_amount,a.invoiceheader_status,supplier_gstno as gst_no,address_state_gid,emp.employee_name,emp.employee_gid,

         a.invoiceheader_gst as IS_GST,
        a.invoiceheader_remarks,i.branch_name,
         i.branch_gid,concat(''['',group_concat( JSON_OBJECT(''metadata_value'',metadata_value,''branch_metadatavalue'',branch_metadatavalue)),'']'' )  as branchdetail
		from ecf_trn_tinvoiceheader as a
		left join gal_mst_tsupplier as b on b.supplier_gid = a.invoiceheader_suppliergid
        left join gal_mst_temployee as emp on emp.employee_gid = a.invoiceheader_employeegid

        left join gal_mst_taddress as e on  e.address_gid = b.supplier_add_gid

		left join  gal_mst_tbranch as i on a.invoiceheader_branchgid = i.branch_gid
        left join
		gal_adm_tentitydetails as j on i.branch_entitydetailsgid = j.entitydetails_gid and  entitydetails_isactive = ''Y'' and entitydetails_isremoved =''N''
		left join gal_adm_tentityheader as k on j.entitydetails_entityheadergid =k.entity_gid and entity_isactive = ''Y'' and entity_isremoved = ''N''
		left join gal_mst_tbranchinfo as l on l.branchinfo_branchgid = i.branch_gid
		left join gal_mst_tmetadata as m on m.metadata_gid = l.branchinfo_metadatagid
		where a.invoiceheader_isactive = ''Y'' and a.invoiceheader_isremoved = ''N''
        and  a.entity_gid = ',li_entity_gid,'
        ' ,Query_Search,'
					');

         Set Query_Group = concat(' group by  a.invoiceheader_gid,branchinfo_branchgid ');

                    ## 23 is Supplier_GST from REF table

		set @p = concat(Query_Select,Query_Group);
		##select Query_Select; ## Remove it
		PREPARE stmt FROM @p;
		EXECUTE stmt;
		Select found_rows() into li_count;
		DEALLOCATE PREPARE stmt;

		if li_count = 0 then
			set Message = 'NOT_FOUND';
		else
			set Message = 'FOUND';
		end if;

elseif Action = 'INVOICE_DETAILS_EDIT' then

		if li_InvoiceHeader_gid = 0 then
			set Message = 'Invoice Header Gid Is Needed.';
            leave sp_ECFInvoice_Get;
        end if;

        set Query_Select = '';
		set Query_Select = concat('select a.invoiceheader_gid,b.invoicedetails_gid,
				c.debit_gid,d.credit_gid,c.debit_categorygid,c.debit_subcategorygid,
				d.credit_bankgid,b.invoicedetails_item,b.invoicedetails_desc,b.invoicedetails_hsncode,
				b.invoicedetails_unitprice,b.invoicedetails_qty,b.invoicedetails_sgst,b.invoicedetails_cgst,
                b.invoicedetails_igst,b.invoicedetails_amount,b.invoicedetails_totalamt,
				c.debit_glno,c.debit_amount,
				d.credit_paymodegid,d.credit_refno,e.bankbranch_ifsccode,e.bankbranch_name,f.bankdetails_beneficiaryname,
				y.suppliertax_taxtype,y.suppliertax_taxrate,d.credit_glno,d.credit_amount,y.suppliertax_panno,
                g.Paymode_name,
                ifnull(d.credit_suppliertaxtype,'''') as credit_suppliertaxtype,
                ifnull(d.credit_suppliertaxtrate,0) as credit_suppliertaxtrate
                ,d.credit_tdsexcempted,ppx.ppxdetails_ppxheadergid,ppx.ppxdetails_gid,(select concat(''['', group_concat(JSON_OBJECT(''ccbs_gid'',
                ccbs.ccbsdtl_gid,''ccbsdtl_debitgid'',ccbs.ccbsdtl_ecfdebitgid
              ,''cc'',ccbs.ccbsdtl_cc,''bs'',ccbs.ccbsdtl_bs,''percentage''
              ,ccbs.ccbsdtl_percent,''ccbsdtl_code'',ccbs.ccbsdtl_code,''Amount'',ccbs.ccbsdtl_amount)) ,'']'') from ecf_trn_tccbsdtl
                as ccbs where ccbs.ccbsdtl_ecfdebitgid = c.debit_gid group by ccbs.ccbsdtl_ecfdebitgid ) as ccbsjsondata

				from ecf_trn_tinvoiceheader as a

                inner join ecf_trn_tinvoicedetails as b on b.invoicedetails_invoiceheadergid = a.invoiceheader_gid and b.invoicedetails_isactive = ''Y''  and b.invoicedetails_isremoved = ''N''
				inner join ecf_trn_tdebit as c on c.debit_invoiceheadergid = a.invoiceheader_gid
                and c.debit_invoicedetailsgid = b.invoicedetails_gid and c.debit_isactive = ''Y'' and c.debit_isremoved = ''N''

				inner join ecf_trn_tcredit as d on d.credit_invoiceheadergid = a.invoiceheader_gid and d.credit_isactive = ''Y'' and d.credit_isremoved = ''N''
				left join ap_trn_tppxdetails as ppx on ppx.ppxdetails_creditgid = d.credit_gid and ppx.ppxdetails_isactive = ''Y''
				left join gal_mst_tbankbranch as e on e.bankbranch_gid = d.credit_bankgid
				inner join gal_mst_tref as z on z.ref_name = ''SUPPLIER_PAYMENT''
				inner join gal_mst_tsuppliertax as y on y.suppliertax_suppliergid = a.invoiceheader_suppliergid
				inner join gal_trn_tbankdetails as f on f.bankdetails_reftable_gid = a.invoiceheader_suppliergid
                and f.bankdetails_ref_gid = z.ref_gid

                left join gal_mst_tpaymode as g on g.paymode_gid = d.credit_paymodegid
                and g.paymode_isactive = ''Y'' and g.paymode_isremoved = ''N''

                where a.invoiceheader_isactive = ''Y'' and a.invoiceheader_isremoved = ''N''



				and z.ref_active = ''Y'' and z.ref_isremoved = ''N''
				and y.suppliertax_isactive = ''Y'' and y.suppliertax_isremoved = ''N''
				and a.invoiceheader_gid = ',li_InvoiceHeader_gid,' and a.entity_gid = ',li_entity_gid,''
						);



     set @p = Query_Select;
   #select Query_Select; ### remove it
     PREPARE stmt FROM @p;
	EXECUTE stmt;
	Select found_rows() into li_count;
	DEALLOCATE PREPARE stmt;

	if li_count = 0 then
		set Message = 'NOT_FOUND';
	else
		set Message = 'FOUND';
	end if;



elseif Action = 'INVOICE_DETAILS_EDIT_EMP' then

		if li_InvoiceHeader_gid = 0 then
			set Message = 'Invoice Header Gid Is Needed.';
            leave sp_ECFInvoice_Get;
        end if;

        set Query_Select = '';
         set Query_Select = concat('select a.invoiceheader_gid,b.invoicedetails_gid,
				c.debit_gid,d.credit_gid,c.debit_categorygid,c.debit_subcategorygid,
				d.credit_bankgid,b.invoicedetails_item,b.invoicedetails_desc,b.invoicedetails_hsncode,
				b.invoicedetails_unitprice,b.invoicedetails_qty,b.invoicedetails_sgst,b.invoicedetails_cgst,
                b.invoicedetails_igst,b.invoicedetails_amount,b.invoicedetails_totalamt,
				c.debit_glno,c.debit_amount,
				d.credit_paymodegid,d.credit_refno,e.bankbranch_ifsccode,e.bankbranch_name,f.bankdetails_beneficiaryname,
                d.credit_glno,d.credit_amount,g.Paymode_name,ppx.ppxdetails_ppxheadergid,ppx.ppxdetails_gid,(select concat(''['', group_concat(JSON_OBJECT(''ccbs_gid'',
                ccbs.ccbsdtl_gid,''ccbsdtl_debitgid'',ccbs.ccbsdtl_ecfdebitgid
              ,''cc'',ccbs.ccbsdtl_cc,''bs'',ccbs.ccbsdtl_bs,''percentage''
              ,ccbs.ccbsdtl_percent,''ccbsdtl_code'',ccbs.ccbsdtl_code,''Amount'',ccbs.ccbsdtl_amount)) ,'']'') from ecf_trn_tccbsdtl
                as ccbs where ccbs.ccbsdtl_ecfdebitgid = c.debit_gid group by ccbs.ccbsdtl_ecfdebitgid ) as ccbsjsondata

				from ecf_trn_tinvoiceheader as a

                inner join ecf_trn_tinvoicedetails as b on b.invoicedetails_invoiceheadergid = a.invoiceheader_gid
				inner join ecf_trn_tdebit as c on c.debit_invoiceheadergid = a.invoiceheader_gid
                and c.debit_invoicedetailsgid = b.invoicedetails_gid
				inner join ecf_trn_tcredit as d on d.credit_invoiceheadergid = a.invoiceheader_gid
				left join ap_trn_tppxdetails as ppx on ppx.ppxdetails_creditgid = d.credit_gid and ppx.ppxdetails_isactive = ''Y''
				left join gal_mst_tbankbranch as e on e.bankbranch_gid = d.credit_bankgid
				inner join gal_mst_tref as z on z.ref_name = ''EMPLOYEE_PAYMENT''
				inner join gal_trn_tbankdetails as f on f.bankdetails_reftable_gid = a.invoiceheader_employeegid
                and f.bankdetails_ref_gid = z.ref_gid
                left join gal_mst_tpaymode as g on g.paymode_gid = d.credit_paymodegid
				where
                a.invoiceheader_isactive = ''Y'' and a.invoiceheader_isremoved = ''N''
				and b.invoicedetails_isactive = ''Y''  and b.invoicedetails_isremoved = ''N''
				and c.debit_isactive = ''Y'' and c.debit_isremoved = ''N''
				and d.credit_isactive = ''Y'' and d.credit_isremoved = ''N''
				and z.ref_active = ''Y'' and z.ref_isremoved = ''N'' and
                a.invoiceheader_gid = ',li_InvoiceHeader_gid,' and a.entity_gid = ',li_entity_gid,''
						);



     set @p = Query_Select;
  ##select Query_Select; ### remove it
     PREPARE stmt FROM @p;
	EXECUTE stmt;
	Select found_rows() into li_count;
	DEALLOCATE PREPARE stmt;

	if li_count = 0 then
		set Message = 'NOT_FOUND';
	else
		set Message = 'FOUND';
	end if;



elseif Action = 'INVOICE_PAYMENT' then
		if ls_invoiceheader_status = '' then
			set Message = 'Invoice Header Status Is Required';
            leave sp_ECFInvoice_Get;
        End if;

       set Query_Select = Concat('select a.invoiceheader_gid,b.supplier_gid,emp.employee_gid,emp.employee_name,c.credit_gid,c.credit_bankgid,c.credit_paymodegid,a.invoiceheader_crno,
		b.supplier_name,a.invoiceheader_invoiceno,
        a.invoiceheader_invoicedate as invoiceheader_invoicedate,
		a.invoiceheader_amount,c.credit_amount,a.invoiceheader_status,d.Paymode_name,a.invoiceheader_invoicetype,ifnull(f.poheader_no,0) as poheader_no,
                (
   CASE
      WHEN a.invoiceheader_invoicetype = ''PO'' or a.invoiceheader_invoicetype = ''Non PO''  THEN
      (SELECT  concat(''['',group_concat( JSON_OBJECT(''bankdetails_gid'',bankdetails_gid,
      ''bankdetails_beneficiaryname'',bankdetails_beneficiaryname,''bankdetails_acno'',bankdetails_acno,
      ''bankbranch_name'',bankbranch_name,''bankbranch_ifsccode'',bankbranch_ifsccode)),'']'' ) FROM gal_trn_tbankdetails as bk
      inner join gal_mst_tbankbranch as br on br.bankbranch_gid = bk.bankdetails_bankbranch_gid
      WHERE  bk.bankdetails_reftable_code = b.Supplier_code)
      ELSE (SELECT  concat(''['',group_concat( JSON_OBJECT(''bankdetails_gid'',bankdetails_gid,
      ''bankdetails_beneficiaryname'',bankdetails_beneficiaryname,''bankdetails_acno'',bankdetails_acno
      ,''bankbranch_name'',bankbranch_name,''bankbranch_ifsccode'',bankbranch_ifsccode)),'']'' ) FROM gal_trn_tbankdetails as bk
      inner join gal_mst_tbankbranch as br on br.bankbranch_gid = bk.bankdetails_bankbranch_gid WHERE  bk.bankdetails_reftable_code = emp.employee_code)
   END
) AS bankdetails
		from ap_trn_tinvoiceheader as a
		left join gal_mst_tsupplier as b on b.supplier_gid = a.invoiceheader_suppliergid
		left join gal_mst_temployee as emp on emp.employee_gid = a.invoiceheader_employeegid
        inner join ap_trn_tcredit as c on c.credit_invoiceheadergid = a.invoiceheader_gid
        inner join gal_mst_tpaymode as  d on d.paymode_gid = c.credit_paymodegid
		left join ap_map_tinvoicepo as e on e.invoicepo_invoiceheadergid = a.invoiceheader_gid
        and e.invoicepo_isactive = ''Y'' and e.invoicepo_isremoved = ''N''
        left join gal_trn_tpoheader as f on f.poheader_gid = e.invoicepo_poheadergid
		and f.poheader_isactive = ''Y'' and f.poheader_isremoved = ''N''
		where a.invoiceheader_status = ''',ls_invoiceheader_status,'''
        and a.invoiceheader_isactive = ''Y'' and a.invoiceheader_isremoved = ''N''
        and a.entity_gid = ',li_entity_gid,'
        and c.credit_isactive = ''Y'' and c.credit_isremoved = ''N''
        and d.paymode_isactive = ''Y'' and d.paymode_isremoved = ''N'' and c.credit_paymodegid in (1,2)

        ');

		set @p = Query_Select;
		##select Query_Select; ### Remove It.
		PREPARE stmt FROM @p;
		EXECUTE stmt;
		Select found_rows() into li_count;
		DEALLOCATE PREPARE stmt;

		if li_count = 0 then
			set Message = 'NOT_FOUND';
		else
			set Message = 'FOUND';
		end if;

elseif Action = 'OVERALL_SUMMARY' then


       set Query_Select = Concat('select a.invoiceheader_gid,a.invoiceheader_crno,a.invoiceheader_invoicetype,a.invoiceheader_invoicedate,
          a.invoiceheader_invoiceno,a.invoiceheader_amount,a.invoiceheader_status,emp.employee_gid,emp.employee_name,b.supplier_name,
          b.supplier_gid,h.paymentdetails_amount,i.paymentheader_amount,i.paymentheader_pvno,g.poheader_no
		from ap_trn_tinvoiceheader as a
         left join inw_trn_tinwarddetails as inw_d on inw_d.inwarddetails_gid = a.invoiceheader_inwarddetailsgid
		left join gal_mst_tsupplier as b on b.supplier_gid = a.invoiceheader_suppliergid
        left join gal_mst_temployee as emp on emp.employee_gid = a.invoiceheader_employeegid
		left join ap_map_tinvoicepo as f on f.invoicepo_invoiceheadergid = a.invoiceheader_gid
        left join gal_trn_tpoheader as g on g.poheader_gid = f.invoicepo_poheadergid
		  left join ap_trn_tpaymentdetails as h on h.paymentdetails_invoiceheadergid = a.invoiceheader_gid
        left join ap_trn_tpaymentheader as i on h.paymentdetails_paymentheadergid = i.paymentheader_gid
 		where
          a.entity_gid = 1 and a.invoiceheader_isactive = ''Y''  group by a.invoiceheader_gid
          order by a.invoiceheader_gid desc
        ');


		set @p = Query_Select;
		##select Query_Select; ### Remove It.
		PREPARE stmt FROM @p;
		EXECUTE stmt;
		Select found_rows() into li_count;
		DEALLOCATE PREPARE stmt;

		if li_count = 0 then
			set Message = 'NOT_FOUND';
		else
			set Message = 'FOUND';
		end if;


elseif Action = 'ECF_DETAILS_EDIT' then


        set Query_Select = '';
		set Query_Select = concat('select a.invoiceheader_gid,b.invoicedetails_gid,b.invoicedetails_discount,
				c.debit_gid,d.credit_gid,c.debit_categorygid,c.debit_subcategorygid,
				d.credit_bankgid,b.invoicedetails_item,b.invoicedetails_desc,b.invoicedetails_hsncode,
				b.invoicedetails_unitprice,b.invoicedetails_qty,b.invoicedetails_sgst,b.invoicedetails_cgst,
                b.invoicedetails_igst,b.invoicedetails_amount,b.invoicedetails_totalamt,
				c.debit_glno,c.debit_amount,
				d.credit_paymodegid,d.credit_refno,e.bankbranch_ifsccode,e.bankbranch_name,f.bankdetails_beneficiaryname,
				d.credit_glno,d.credit_amount,
                g.Paymode_name,
                ifnull(d.credit_suppliertaxtype,'''') as credit_suppliertaxtype,
                ifnull(d.credit_suppliertaxtrate,0) as credit_suppliertaxtrate
                ,d.credit_tdsexcempted,ppx.ppxdetails_ppxheadergid,ppx.ppxdetails_gid,(select concat(''['', group_concat(DISTINCT JSON_OBJECT(''Debit_gid'',debit_gid,''Invoice_Header_Gid'','''',''Invoice_Details_Gid'','''',
				''Category_Gid'',debit_categorygid,''Sub_Category_Gid'',debit_subcategorygid,''GL_No'',debit_glno,''cc_id'',ccbsdtl_cc,''bs_id'',ccbsdtl_bs,''percent'',ccbsdtl_percent,''Debit_Amount'',debit_amount,''Invoice_Sno'','''',''tbs_name'',tbs_name,''CCBS'',

         (select concat(''['',JSON_OBJECT(''total_ccbbs_amt'','''', ''CCBS_JSON'',concat(''['',group_concat(JSON_OBJECT(''ccbs_gid'',ccbs.ccbsdtl_gid,''cc'',ccbs.ccbsdtl_cc,''Amount'',ccbs.ccbsdtl_amount,''bs'',ccbs.ccbsdtl_bs,''percentage'',ccbs.ccbsdtl_percent)) ,'']'')),'']'') from ap_trn_tccbsdtl
	      as ccbs where ccbs.ccbsdtl_debitgid = debit_gid group by ccbs.ccbsdtl_debitgid ))order by debit_gid) ,'']'')

        )as DEBIT_DETAILS
				from ecf_trn_tinvoiceheader as a

                inner join ecf_trn_tinvoicedetails as b on b.invoicedetails_invoiceheadergid = a.invoiceheader_gid and
									b.invoicedetails_isactive = ''Y''  and b.invoicedetails_isremoved = ''N''
				inner join ecf_trn_tdebit as c on c.debit_invoiceheadergid = a.invoiceheader_gid
                and c.debit_invoicedetailsgid = b.invoicedetails_gid 	and c.debit_isactive = ''Y'' and c.debit_isremoved = ''N''
                inner join ecf_trn_tccbsdtl as ccb on ccb.ccbsdtl_ecfdebitgid = c.debit_gid  and ccb.ccbsdtl_isactive = ''Y'' and ccb.ccbsdtl_isremoved = ''N''
                inner join ap_mst_tbs as bs on bs.tbs_gid = ccb.ccbsdtl_bs
				left join ecf_map_tecfinvoicepo as pomap on pomap.ecfinvoicepo_invoicedetailsgid = b.invoicedetails_gid
				inner join ecf_trn_tcredit as d on d.credit_invoiceheadergid = a.invoiceheader_gid and d.credit_isactive = ''Y'' and d.credit_isremoved = ''N''
				left join ecf_trn_tecfppxdetails as pp on pp.ecfppxdetails_creditgid = d.credit_gid
				left join ap_trn_tppxheader as pph on pph.ppxheader_gid = pp.ecfppxdetails_ecfppxheadergid
                left join ap_trn_tppxdetails as ppx on ppx.ppxdetails_creditgid = d.credit_gid and ppx.ppxdetails_isactive = ''Y''
				left join gal_mst_tbankbranch as e on e.bankbranch_gid = d.credit_bankgid
				inner join gal_mst_tref as z on z.ref_name = ''SUPPLIER_PAYMENT''

				left join gal_trn_tbankdetails as f on f.bankdetails_reftable_gid = a.invoiceheader_suppliergid
                and f.bankdetails_ref_gid = z.ref_gid

                left join gal_mst_tpaymode as g on g.paymode_gid = d.credit_paymodegid
                and g.paymode_isactive = ''Y'' and g.paymode_isremoved = ''N''

                where a.invoiceheader_isactive = ''Y'' and a.invoiceheader_isremoved = ''N''

				and z.ref_active = ''Y'' and z.ref_isremoved = ''N''

				and a.invoiceheader_crno = ''',ls_ECF_Number,''' and a.entity_gid = ',li_entity_gid,' group by b.invoicedetails_gid,credit_gid '
						);



     set @p = Query_Select;
	#select Query_Select; ### remove it
     PREPARE stmt FROM @p;
	EXECUTE stmt;
	Select found_rows() into li_count;
	DEALLOCATE PREPARE stmt;

	if li_count = 0 then
		set Message = 'NOT_FOUND';
	else
		set Message = 'FOUND';
	end if;



elseif Action = 'ECF_DETAILS_EDIT_EMP' then



        set Query_Select = '';
         set Query_Select = concat('select a.invoiceheader_gid,b.invoicedetails_gid,
				c.debit_gid,d.credit_gid,c.debit_categorygid,c.debit_subcategorygid,
				d.credit_bankgid,b.invoicedetails_item,b.invoicedetails_desc,b.invoicedetails_hsncode,
				b.invoicedetails_unitprice,b.invoicedetails_qty,b.invoicedetails_sgst,b.invoicedetails_cgst,
                b.invoicedetails_igst,b.invoicedetails_amount,b.invoicedetails_totalamt,
				c.debit_glno,c.debit_amount,
				d.credit_paymodegid,d.credit_refno,e.bankbranch_ifsccode,e.bankbranch_name,f.bankdetails_beneficiaryname,
                d.credit_glno,d.credit_amount,g.Paymode_name,ppx.ppxdetails_ppxheadergid,ppx.ppxdetails_gid,(select concat(''['', group_concat(DISTINCT JSON_OBJECT(''Debit_gid'',debit_gid,''Invoice_Header_Gid'','''',''Invoice_Details_Gid'','''',
				''Category_Gid'',debit_categorygid,''Sub_Category_Gid'',debit_subcategorygid,''GL_No'',debit_glno,''Debit_Amount'',debit_amount,''Invoice_Sno'','''',''CCBS'',

         (select concat(''['',JSON_OBJECT(''total_ccbbs_amt'','''', ''CCBS_JSON'',concat(''['',group_concat(JSON_OBJECT(''ccbs_gid'',ccbs.ccbsdtl_gid,''cc'',ccbs.ccbsdtl_cc,''Amount'',ccbs.ccbsdtl_amount,''bs'',ccbs.ccbsdtl_bs,''percentage'',ccbs.ccbsdtl_percent)) ,'']'')),'']'') from ecf_trn_tccbsdtl
	      as ccbs where ccbs.ccbsdtl_ecfdebitgid = debit_gid group by ccbs.ccbsdtl_ecfdebitgid ))order by debit_gid) ,'']'')

        )as DEBIT_DETAILS, pomap.ecfinvoicepo_poheadergid,pomap.ecfinvoicepo_podetailsgid,pomap.ecfinvoicepo_grninwardheadergid,pomap.ecfinvoicepo_grninwarddetailsgid,pomap.ecfinvoicepo_qty,ecfppxdetails_ecfppxheadergid as ppxheadergid,pph.ppxheader_crno


				from ecf_trn_tinvoiceheader as a

                inner join ecf_trn_tinvoicedetails as b on b.invoicedetails_invoiceheadergid = a.invoiceheader_gid
				inner join ecf_trn_tdebit as c on c.debit_invoiceheadergid = a.invoiceheader_gid
                and c.debit_invoicedetailsgid = b.invoicedetails_gid
				left join ecf_map_tecfinvoicepo as pomap on pomap.ecfinvoicepo_invoicedetailsgid = b.invoicedetails_gid
				inner join ecf_trn_tcredit as d on d.credit_invoiceheadergid = a.invoiceheader_gid
				left join ecf_trn_tecfppxdetails as pp on pp.ecfppxdetails_creditgid = d.credit_gid
				left join ap_trn_tppxheader as pph on pph.ppxheader_gid = pp.ecfppxdetails_ecfppxheadergid

                left join ap_trn_tppxdetails as ppx on ppx.ppxdetails_creditgid = d.credit_gid and ppx.ppxdetails_isactive = ''Y''
				left join gal_mst_tbankbranch as e on e.bankbranch_gid = d.credit_bankgid
				inner join gal_mst_tref as z on z.ref_name = ''EMPLOYEE_PAYMENT''
				left join gal_trn_tbankdetails as f on f.bankdetails_reftable_gid = a.invoiceheader_employeegid
                and f.bankdetails_ref_gid = z.ref_gid
                left join gal_mst_tpaymode as g on g.paymode_gid = d.credit_paymodegid
				where
                a.invoiceheader_isactive = ''Y'' and a.invoiceheader_isremoved = ''N''
				and b.invoicedetails_isactive = ''Y''  and b.invoicedetails_isremoved = ''N''
				and c.debit_isactive = ''Y'' and c.debit_isremoved = ''N''
				and d.credit_isactive = ''Y'' and d.credit_isremoved = ''N''
				and z.ref_active = ''Y'' and z.ref_isremoved = ''N'' and
                a.invoiceheader_crno = ''',ls_ECF_Number,''' and a.entity_gid = ',li_entity_gid,' group by b.invoicedetails_gid,d.credit_gid'
						);



     set @p = Query_Select;
 ##select Query_Select; ### remove it
     PREPARE stmt FROM @p;
	EXECUTE stmt;
	Select found_rows() into li_count;
	DEALLOCATE PREPARE stmt;

	if li_count = 0 then
		set Message = 'NOT_FOUND';
	else
		set Message = 'FOUND';
	end if;



elseif Action = 'ECF_HEADERGET' then
		if ls_ECF_Number = '' then
			set Message = 'Ecf No Is Required';
            leave sp_ECFInvoice_Get;
        End if;

       set Query_Select = Concat('select invoiceheader_crno,invoiceheader_invoicetype,invoiceheader_employeegid,invoiceheader_suppliergid,
			  invoiceheader_supplierstategid,invoiceheader_invoicedate,invoiceheader_invoiceno,invoiceheader_amount,
			  invoiceheader_remarks,invoiceheader_gst,invoiceheader_branchgid
			 from ecf_trn_tinvoiceheader where invoiceheader_crno =''',ls_ECF_Number,'''  and
			  invoiceheader_isactive=''Y''  and  entity_gid = ',li_entity_gid,' and invoiceheader_status = ''Approved''
					');


		set @p = Query_Select;
		#select Query_Select; ### Remove It.
		PREPARE stmt FROM @p;
		EXECUTE stmt;
		Select found_rows() into li_count;
		DEALLOCATE PREPARE stmt;

		if li_count = 0 then
			set Message = 'NOT_FOUND';
		else
			set Message = 'FOUND';
		end if;

	 ## End of ACTION
	End if; ## End of ACTION



END