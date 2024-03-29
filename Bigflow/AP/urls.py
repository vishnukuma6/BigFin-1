from django.urls import path
from Bigflow.AP import views

urlpatterns = [
    path('billentry/', views.billentryIndex, name='billentry'),
    path('billentry_checker/', views.billentry_checker, name='billentry'),
    path('ECF_billentry_checker/', views.ECF_billentry_checker, name='billentry'),
    path('POinvoicemk/', views.POinvoice, name="POinvoice" ),
    path('getgrndetail/',views.getgrndetail, name='getgrndetail'),
    path('Invoicesummary/', views.Invoicesummary , name='Invoicesummary'),
    path('AP_Report/', views.AP_Report , name='Invoicesummary'),
    path('GL_Report/', views.GL_Report , name='GL_Report'),
    path('gl_day_entry_generate/', views.gl_day_entry_generate , name='gl_day_entry_generate'),
    path('inwarddtl_get/', views.inwarddtl_get , name='inwarddtl_get'),
    path('Inward_entry/', views.Inward_entry , name='Inward_entry'),
    path('Invoice_set/', views.Invoice_set , name='Invoice_set'),
    path('APInvoice_get/',views.APInvoice_get, name='APInvoice_get'),
    path('makersummary/', views.Makersummary , name='makersummary'),
    path('Credit_get/', views.Credit_get , name='Credit_get'),
    path('Invoiceheader_set/' , views.Invoiceheader_set , name='Invoiceheader_set'),
    path('Dynamic_Invoiceheader_set/' , views.Dynamic_Invoiceheader_set , name='Dynamic_Invoiceheader_set'),
    path('Dynamic_Status_Update/' , views.Dynamic_Status_Update , name='Dynamic_Status_Update'),
    path('HSN_get/' , views.HSN_get , name='HSN_get'),
    path('Hsntax_get/', views.Hsntax_get , name='Hsntax_get'),
    path('tablevalue/', views.tablevalue, name = 'tablevalue'),
    path('ap_cat_get_sp/', views.ap_cat_get_sp, name = 'ap_cat_get_sp'),
    path('ap_paymode_details/', views.ap_paymode_details, name = 'ap_paymode_details'),
    path('get_subcategory_data/', views.get_subcategory_data, name = 'get_subcategory_data'),
    path('Checkersummary/', views.Checkersummary, name = 'Checkersummary'),
    path('HsntaxCredit_get/', views.HsntaxCredit_get , name='HsntaxCredit_get'),
    path('APInvoiceChecker_get/', views.APInvoiceChecker_get , name='APInvoiceChecker_get'),
    path('Approvalsummary/', views.Approvalsummary, name='Approvalsummary'),
    path('AP_History/', views.AP_History, name='AP_History'),
    path('AP_History_get/', views.AP_History_get, name='AP_History_get'),
    path('PreparePayment/', views.PreparePayment , name='Paymentsummary'),
    path('PrepareFile/', views.PrepareFile , name='PrepareFile'),
    path('Paymentupdate/', views.paymentupdate, name = 'paymentstatus'),
    path('APpayment_set/', views.APpayment_set, name="Appaymentset"),
    path('Rejectsummary/', views.Rejectsummary , name='Rejectsummary'),
    path('claimrejection/', views.claimrejection, name='claimrejection'),
    path('Rejectdata/', views.Rejectdata , name = 'Rejectdata'),
    path('Getreason_data/', views.Getreason_data , name= 'Getreason_data'),
    path('APrejectinv_set/', views.APrejectinv_set ,name='APrejectinv_set'),
    path('Paymmentdtl_get/', views.Paymmentdtl_get , name='Paymmentdtl_get'),
    path('billentryedit/', views.billentryedit , name='billentryedit'),
    path('Dropdown_detail_ap/', views.Dropdown_detail_ap, name='Dropdown_details'),
    path('PPPXDeatails_get/', views.PPPXDeatails_get, name='PPPXDeatails_get'),
    path('PPPXDeatails_set/', views.PPPXDeatails_set, name='PPPXDeatails_set'),
    path('APsummary/', views.APsummary, name='APsummary'),
    path('getpayment_excel/', views.getpayment_excel, name='getpayment_excel'),
    path('Dispatch_Payment/', views.Dispatch_Set_Payment, name='getpayment_excel'),
    path('auditchklist_get/', views.auditchklist_get, name='auditchklist_get'),
    path('auditchklist_set/', views.auditchklist_set, name='auditchklist_get'),
    path('Get_address_ap/', views.Get_address_ap, name='Get_address_ap'),
    path('PaymentStatus/', views.AP_PaymentStatus, name='AP_PaymentStatus.html'),
    path('PODDispatch_Set_AP/', views.PODDispatch_Set_AP, name='PODDispatch_Set_AP'),
    path('upload_image_ap/', views.upload_image_ap, name='upload_image_ap'),
    path('APStale_set/', views.APStale_set, name='APStale_set'),
    path('APNeftExcel_downld/', views.APNeftExcel_downld, name='APNeftExcel_downld'),
    path('Stalesummary/', views.Stalesummary, name='Stalesummary'),
    path('stalesummary_get/', views.stalesummary_get, name='stalesummary_get'),
    path('classificationdata_get/', views.classificationdata_get, name='classificationdata_get'),
    path('supplierdata_get/', views.supplierdata_get, name='supplierdata_get'),
    path('EmployeeQuery/', views.Ap_EmployeeQuery, name='Ap_EmployeeQuery'),
    path('ECF_AP_Billentry_Checker/', views.ECF_AP_Billentry_Checker, name='ECF_AP_Billentry_Checker'),
    path('EmployeeQuery_demo/', views.Ap_EmployeeQuery_demo, name='Ap_EmployeeQuery'),
    path('Ecf_ClaimQuery/', views.Ecf_ClaimQuery, name='Ecf_ClaimQuery'),
    path('Ecf_ClaimQueryCO_DO/', views.Ecf_ClaimQueryCO_DO, name='Ecf_ClaimQueryCO_DO'),
    path('AP_GL_Balance/', views.AP_GL_Balance, name='AP_GL_Balance'),
    path('AP_Accounting_Entry_Query/', views.AP_Accounting_Entry_Query, name='AP_Accounting_Entry_Query'),
    path('AP_Accounting_WiseFin_Entry_Query/', views.AP_Accounting_WiseFin_Entry_Query, name='AP_Accounting_WiseFin_Entry_Query'),
    path('get_Accounting_Entry_Data/', views.get_Accounting_Entry_Data, name='get_Accounting_Entry_Data'),
    path('Bounce/', views.Ap_Bounce, name='Ap_Bounce'),
    path('Invoiceheader_Mail_set/', views.Invoiceheader_Mail_set, name='Invoiceheader_Mail_set'),
    path('get_Mail_Templates_Data/', views.get_Mail_Templates_Data, name='get_Mail_Templates_Data'),
    path('common_lock_data/', views.common_lock_data, name='common_lock_data'),
    path('ap_all_table_values_get/', views.ap_all_table_values_get, name='ap_all_table_values_get'),
    path('ap_set_dispatch/', views.ap_set_dispatch, name='ap_set_dispatch'),
    path('ap_get_dispatch/', views.ap_get_dispatch, name='ap_get_dispatch'),
    path('pmd_branch_summary/', views.pmd_branch_summary, name='pmd_branch_summary'),
    path('pmd_create/', views.pmd_create, name='pmd_create'),
    path('AP_Failed_Transaction/', views.AP_Failed_Transaction, name='AP_Failed_Transaction'),
    path('AP_Advance_Summary/', views.AP_Advance_Summary, name='AP_Advance_Summary'),
    path('AP_Entry_Update_Summary/', views.AP_Entry_Update_Summary, name='AP_Entry_Update_Summary'),
    path('get_pmd_data/', views.get_pmd_data, name='get_pmd_data'),
    path('set_pmd_data/', views.set_pmd_data, name='set_pmd_data'),
    path('advance_get/', views.advance_get, name='advance_get'),
    path('entry_update_get/', views.entry_update_get, name='entry_update_get'),
    path('entry_update_set/', views.entry_update_set, name='entry_update_set'),


    path('bill/', views.bill, name='billentry'),

    #ecf
    path('ECFinventry/', views.Ecf_Invoiceentry, name='ECFinventry'),
    path('EcfInvoicevalue_get/', views.EcfInvoicevalue_get, name='EcfInvoicevalue_get'),
    path('ECFInvoiceheader_set/', views.ECFInvoiceheader_set, name='ECFInvoiceheader_set'),
    path('ECF_Multiple_Approve/', views.ECF_Multiple_set, name='ECFInvoiceheader_set'),
    path('ECFInvoice_get/', views.ECFInvoice_get, name='ECFInvoice_get'),
    path('Ecf_billentry/', views.Ecf_billentry, name='Ecf_billentry'),
    path('ECFInvoice_set/', views.ECFInvoice_set, name='ECFInvoice_set'),
    path('ECFPOinvoicemk/', views.ECFPOinvoicemk, name="ECFPOinvoicemk"),
    path('ECFApproval/', views.ECFApproval, name="ECFApproval"),
    path('ECFInvoiceChecker_get/', views.ECFInvoiceChecker_get, name="ECFInvoiceChecker_get"),
    path('APECF_entry/', views.APECF_entry, name="APECF_entry"),
    path('ECFSummary/', views.ECFSummary, name="ECFSummary"),
    path('ECF_ApChecker_get/', views.ECF_ApChecker_get, name="ECF_ApChecker_get"),
    path('ECF_Process_get/', views.ECF_Process_Get, name="ECF_ApChecker_get"),

    path('ECFinventryCO/', views.Ecf_InvoiceentryCO, name='ECFinventryCO'),
    path('ECFinventryCO_Summary/', views.ECFinventryCO_Summary, name='ECFinventryCO_Summary'),


    #AP_Onward_Invoice
    path('Onward_Invoice/',views.AP_Onward_Invoice,name="AP_Onward_Invoice"),
    path('Onward_Sale_Approval/',views.AP_Onward_Sale_Approval,name="Onward_Sale_Approval"),
    path('AP_Onward_Sale_Summary/',views.AP_Onward_Sale_Summary,name="AP_Onward_Sale_Summary"),
    path('AP_Ammort_Summary/',views.AP_Ammort_Summary,name="AP_Ammort_Summary"),
    path('AP_Ammort_Schedule_Summary/',views.AP_Ammort_Schedule_Summary,name="AP_Ammort_Schedule_Summary"),
    path('AP_Ammort_Schedule_Creation/',views.AP_Ammort_Schedule_Creation,name='AP_Ammort_Schedule_Creation'),
    path('AP_Ammort_Approval_Summary/',views.AP_Ammort_Approval_Summary,name='AP_Ammort_Approval_Summary'),
    path('AP_Ammort_Approval/',views.AP_Ammort_Approval,name='AP_Ammort_Approval'),
    path('AP_Ammort_Schedule_Process/',views.AP_Ammort_Schedule_Process,name='AP_Ammort_Schedule_Process'),
    path('AP_Ammort_Edit/',views.AP_Ammort_Edit,name='AP_Ammort_Edit'),
    path('get_APbankdetails/',views.get_APbankdetails,name='get_APbankdetails'),

    path('get_onward_invoice/',views.get_Onward_Invoice,name="get_Onward_Invoice"),
    path('set_onward_invoice/',views.set_Onward_Invoice,name="get_Onward_Invoice"),
    path('get_onward_data/',views.get_Onward_data,name="get_Onward_Invoice"),
    path('get_onward_data_demo/',views.get_Onward_data_demo,name="get_Onward_Invoice"),
    path('get_tablevalue/',views.get_tablevalue,name="get_tablevalue"),
    path('get_subcate_data/',views.get_subcat,name="get_tablevalue"),
    path('get_ccbs_data/',views.get_ccbs_data,name="get_ccbs_data"),

    path('set_ammort/', views.set_Ammort,name="set_ammort"),
    path('ap_initail_and_accounting_entry/', views.ap_initail_and_accounting_entry,name="ap_initail_and_accounting_entry"),
    path('ap_entry_details_get_amount_transfer_api/', views.ap_entry_details_get_amount_transfer_api,name="ap_entry_details_get_amount_transfer_api"),
    path('get_ammort/', views.get_Ammort,name="get_ammort"),


    path('run_ammort/', views.run_ammort,name="run_ammort"),
    path('run_standardinstruction/', views.run_standardinstruction,name="run_standardinstruction"),
    path('run_branchexp/', views.run_branchexp,name="run_branchexp"),

    # emp bank Get
    path('Mst_Emp_Bank/', views.Mst_Emp_Bank, name="Mst_Emp_Bank"),
    path('Mst_Branch_Bank/', views.Mst_Branch_Bank, name="Mst_Branch_Bank"),
    path('get_bank_data/', views.get_bank_data, name="get_bank_data"),
    path('Get_Supplier/', views.get_supplier, name="get_supplier"),

    path('APInvoice_get_/', views.APInvoice_get_, name="APInvoice_get_"),
    path('get_dedube_data/', views.getDedubeData, name="get_dedube"),

    #ecf generation
    path('render_to_pdf/', views.html_pdf, name="render_to_pdf"),
    path('down_pdf/', views.down_pdf, name="down_pdf"),

    path('get_delmat_data/', views.get_delmat, name="down_pdf"),
    path('get_bank_details/', views.get_bank_details, name="get_bank_details"),

    path('AP_to_FA_API/', views.fa_accounging_entry, name='fa_accounting_entry'),
    path('Session_Get_AP_Data/', views.Session_Get_AP_Data, name='Session_Get_AP_Data'),
    path('set_file_details/', views.set_file_details, name='set_file_details'),
    path('get_GL_Report/', views.get_GL_Report, name='get_GL_Report'),
    path('ECF_Claim_Status_Report/', views.ECF_Claim_Status_Report, name='ECF_Claim_Status_Report'),
    path('ecf_common_report/', views.ecf_common_report, name='ecf_common_report'),

]