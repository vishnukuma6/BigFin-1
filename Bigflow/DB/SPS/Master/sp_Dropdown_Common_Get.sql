CREATE DEFINER=`developer`@`%` PROCEDURE `galley`.`sp_Dropdown_Common_Get`(IN `tbl_name` varchar(64),IN `li_gid` int,
IN `ls_name` varchar(64),IN `li_entity_gid` int,out `Message` varchar(1024))
sp_Dropdown_Common_Get:BEGIN

#Vigneshwari       21-11-2017

declare Query_search varchar(1000);
declare query1 varchar(1000);
declare li_count int;

if li_entity_gid <= 0 then
	set Message = 'Entity Gid Is Needed.';
    leave sp_Dropdown_Common_Get;
End if;

if tbl_name <> '' then

	if li_gid <> 0 then
		set Query_search = concat(' and ' , tbl_name , '_gid = ' , li_gid);
	else
		set Query_search = '';
	end if;

    if ls_name <> '' then
		set query_search = concat(Query_search , ' and ' , tbl_name , '_name like ''%' , ls_name , '%'' ');
	else
		set Query_search = concat(Query_search , '');
	end if;

	set query1 = concat('select ', tbl_name , '_gid,' , tbl_name , '_name,' , tbl_name , '_code from gal_mst_t' , tbl_name ,
						' where ', tbl_name , '_isremoved = ''N''  and entity_gid = ',li_entity_gid,' ');

	set @p = concat(query1 , Query_search );
	PREPARE stmt FROM @p;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;

							Select found_rows() into li_count;

							  if li_count > 0 then
									set Message = 'FOUND';
							  else
									set Message = 'NOT_FOUND';
							  end if;


end if;
END