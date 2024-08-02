--select * from 
create or replace view v_sup_ledgerold as
(

SELECT A.SET_OF_BOOKS_ID,
            A.org_id,
            A.vendor_num vendor_num_smry,
            A.VENDOR_ID,
            A.vendor_site_id,
            A.vendor_site_code vendor_site_code_smry,
            A.vendor_name vendor_name_smry,
            A.gl_date gl_date_smry,
            A.vouchar vouchar_smry,
            A.INVOICE_TYPE_LOOKUP_CODE INVOICE_TYPE_LOOKUP_CODE_smry,
            A.DESCRIPTION DESCRIPTION_smry,
            A.Invoice_ID,
            A.INVOICE_NUM INVOICE_NUM_smry,
            A.INVOICE_CURRENCY_CODE INVOICE_CURRENCY_CODE_smry,
            SUM (NVL (A.DR_FC, 0)) DR_FC_smry,
            SUM (NVL (A.CR_FC, 0)) CR_FC_smry,
            SUM (NVL (A.DR, 0)) DR_smry,
            SUM (NVL (A.CR, 0)) CR_smry
       FROM (SELECT pv.SEGMENT1 vendor_num,
                    pvsa.VENDOR_SITE_CODE,
                    pv.vendor_name vendor_name,
                    pha.segment1 po_number,
                    aila.gl_date,
                    aila.inventory_item_id,
                    aila.po_header_id,
                    aia.wfapproval_status invoice_status,
                    aia.doc_sequence_value vouchar,
                    DECODE (aila.pay_awt_group_name,
                            NULL, aila.awt_group_name,
                            aila.pay_awt_group_name)
                       wht_group,
                    aia.EXCHANGE_RATE,
                    aia.INVOICE_CURRENCY_CODE,
                    aila.line_type_lookup_code,
                    aia.invoice_id,
                    NULL invoice_payment_id,
                    aia.vendor_id,
                    aia.invoice_type_lookup_code,
                    NULL AS check_number,
                    aia.invoice_num,
                    aia.description,
                    aia.invoice_date,
                    NULL AS CHECK_DATE,
                    aila.amount invoice_amount,
                    DECODE (
                       LINE_TYPE_LOOKUP_CODE,
                       'AWT', DECODE (
                                 SIGN (aila.AMOUNT),
                                 -1, DECODE (
                                        AIA.INVOICE_CURRENCY_CODE,
                                        'PKR', ABS (aila.amount),
                                        (AIA.EXCHANGE_RATE * ABS (aila.amount)))),
                    /*   'TAX', DECODE (
                                 SIGN (aila.AMOUNT),
                                 -1, DECODE (
                                        AIA.INVOICE_CURRENCY_CODE,
                                        'PKR', ABS (aila.amount),
                                        (AIA.EXCHANGE_RATE * ABS (aila.amount)))),*/
                       'ITEM', DECODE (
                                  SIGN (aila.AMOUNT),
                                  -1, DECODE (
                                         AIA.INVOICE_CURRENCY_CODE,
                                         'PKR', ABS (aila.amount),
                                         (AIA.EXCHANGE_RATE * ABS (aila.amount)))))
                       DR,
                    DECODE (
                       invoice_type_lookup_code,
                       'STANDARD', DECODE (
                                      LINE_TYPE_LOOKUP_CODE,
                                      'AWT', DECODE (
                                                SIGN (aila.AMOUNT),
                                                1, DECODE (
                                                      AIA.INVOICE_CURRENCY_CODE,
                                                      'PKR', ABS (aila.amount),
                                                      (  AIA.EXCHANGE_RATE
                                                       * ABS (aila.amount)))),
                                      'TAX', DECODE (
                                                SIGN (aila.AMOUNT),
                                                1, DECODE (
                                                      AIA.INVOICE_CURRENCY_CODE,
                                                      'PKR', ABS (aila.amount),
                                                      (  AIA.EXCHANGE_RATE
                                                       * ABS (aila.amount)))),
                                      'ITEM', DECODE (
                                                 SIGN (aila.AMOUNT),
                                                 1, DECODE (
                                                       AIA.INVOICE_CURRENCY_CODE,
                                                       'PKR', ABS (aila.amount),
                                                       (  AIA.EXCHANGE_RATE
                                                        * ABS (aila.amount)))),
                                      DECODE (
                                         AIA.INVOICE_CURRENCY_CODE,
                                         'PKR', ABS (aila.amount),
                                         (AIA.EXCHANGE_RATE * ABS (aila.amount)))),
                       'EXPENSE REPORT', DECODE (
                                            LINE_TYPE_LOOKUP_CODE,
                                            'AWT', 0,
                                            DECODE (
                                               AIA.INVOICE_CURRENCY_CODE,
                                               'PKR', ABS (aila.amount),
                                               (  AIA.EXCHANGE_RATE
                                                * ABS (aila.amount)))),
                       'AWT', DECODE (
                                 LINE_TYPE_LOOKUP_CODE,
                                 'AWT', 0,
                                 DECODE (
                                    AIA.INVOICE_CURRENCY_CODE,
                                    'PKR', ABS (aila.amount),
                                    (AIA.EXCHANGE_RATE * ABS (aila.amount)))),
                       'MIXED', DECODE (
                                   LINE_TYPE_LOOKUP_CODE,
                                   'ITEM', DECODE (
                                              SIGN (aila.AMOUNT),
                                              1, DECODE (
                                                    AIA.INVOICE_CURRENCY_CODE,
                                                    'PKR', ABS (aila.amount),
                                                    (  AIA.EXCHANGE_RATE
                                                     * ABS (aila.amount))))))
                       CR,
                    DECODE (
                       LINE_TYPE_LOOKUP_CODE,
                       'AWT', DECODE (
                                 SIGN (aila.AMOUNT),
                                 -1, DECODE (AIA.INVOICE_CURRENCY_CODE,
                                             'PKR', 0,
                                             (ABS (aila.amount)))),
                      /* 'TAX', DECODE (
                                 SIGN (aila.AMOUNT),
                                 -1, DECODE (AIA.INVOICE_CURRENCY_CODE,
                                             'PKR', 0,
                                             (ABS (aila.amount)))),*/
                       'ITEM', DECODE (
                                  SIGN (aila.AMOUNT),
                                  -1, DECODE (AIA.INVOICE_CURRENCY_CODE,
                                              'PKR', 0,
                                              (ABS (aila.amount)))))
                       DR_FC,
                    DECODE (
                       invoice_type_lookup_code,
                       'STANDARD', DECODE (
                                      LINE_TYPE_LOOKUP_CODE,
                                      'AWT', DECODE (
                                                SIGN (aila.AMOUNT),
                                                1, DECODE (
                                                      AIA.INVOICE_CURRENCY_CODE,
                                                      'PKR', 0,
                                                      (ABS (aila.amount)))),
                                      'TAX', DECODE (
                                                SIGN (aila.AMOUNT),
                                                1, DECODE (
                                                      AIA.INVOICE_CURRENCY_CODE,
                                                      'PKR', 0,
                                                      (ABS (aila.amount)))),
                                      'ITEM', DECODE (
                                                 SIGN (aila.AMOUNT),
                                                 1, DECODE (
                                                       AIA.INVOICE_CURRENCY_CODE,
                                                       'PKR', 0,
                                                       (ABS (aila.amount)))),
                                      DECODE (AIA.INVOICE_CURRENCY_CODE,
                                              'PKR', 0,
                                              (ABS (aila.amount)))),
                       'EXPENSE REPORT', DECODE (
                                            LINE_TYPE_LOOKUP_CODE,
                                            'AWT', 0,
                                            DECODE (AIA.INVOICE_CURRENCY_CODE,
                                                    'PKR', 0,
                                                    (ABS (aila.amount)))),
                       'AWT', DECODE (
                                 LINE_TYPE_LOOKUP_CODE,
                                 'AWT', 0,
                                 DECODE (AIA.INVOICE_CURRENCY_CODE,
                                         'PKR', 0,
                                         (ABS (aila.amount)))),
                       'MIXED', DECODE (
                                   LINE_TYPE_LOOKUP_CODE,
                                   'ITEM', DECODE (
                                              SIGN (aila.AMOUNT),
                                              1, DECODE (
                                                    AIA.INVOICE_CURRENCY_CODE,
                                                    'PKR', 0,
                                                    (ABS (aila.amount))))))
                       CR_FC,
                    DECODE (cancelled_date, NULL, 'N', 'Y') cancelled,
                    'A' tag,
                    NULL OP_CR,
                    NULL OP_DR,
                    aia.org_id,
                    aia.SET_OF_BOOKS_ID,
                    'Opening Balance' AS opn_bal,
                    NULL un_invoiced,
                    PVSA.VENDOR_SITE_ID,
                    NULL AS ACC_DATE
               FROM ap_invoices_all aia,
                    ap_invoice_lines_v aila,
                    po_vendors pv,
                    Po_vendor_sites_all pvsa,
                    po_headers_all pha
              WHERE     invoice_type_lookup_code IN
                           ('STANDARD', 'PREPAYMENT', 'EXPENSE REPORT', 'MIXED')
                    AND aila.invoice_id = aia.invoice_id
                    AND aila.VALIDATION_STATUS IN
                           ('APPROVED', 'NEEDS REAPPROVAL')
                    AND (   aia.PAY_GROUP_LOOKUP_CODE NOT IN
                               ('RETENTION_MONEY', 'SECURITY_DEPOSIT')
                         OR aia.PAY_GROUP_LOOKUP_CODE IS NULL)
                    AND pv.vendor_id = aia.vendor_id
                    AND pv.VENDOR_ID = pvsa.VENDOR_ID
                    AND pvsa.VENDOR_SITE_ID = aia.VENDOR_SITE_ID
                    AND pha.po_header_id(+) = aila.po_header_id
                    AND aila.LINE_TYPE_LOOKUP_CODE NOT IN ('PREPAY')
                    AND aila.VALIDATION_STATUS IN
                           ('APPROVED', 'NEEDS REAPPROVAL')
                    AND aila.cancelled_flag = 'N'
                    -- and aia.vendor_id  = nvl(:p_vendor_id,aia.vendor_id) --in (select vendor_id from po_vendors where segment1 between vend_f and vend_t)
                    --and pvsa.VENDOR_SITE_ID = nvl(:P_VENDOR_SITE_ID,pvsa.VENDOR_SITE_ID)
                    --AND TRUNC(aila.gl_date) BETWEEN :p_date_from AND :CP_GL_TO_DATE
                    -- and aia.org_id=nvl(:p_org_id,aia.org_id)

                    -- AND aia.SET_OF_BOOKS_ID = nvl(:p_legder,aia.SET_OF_BOOKS_ID)
                    -- and (pv.VENDOR_TYPE_LOOKUP_CODE = nvl(:p_vendor_type,VENDOR_TYPE_LOOKUP_CODE) OR pv.VENDOR_TYPE_LOOKUP_CODE IS NULL)
                    --and aia.INVOICE_TYPE_LOOKUP_CODE = nvl(:p_INVOICE_TYPE,aia.INVOICE_TYPE_LOOKUP_CODE)
                    AND (cancelled_date IS NULL OR cancelled_date > SYSDATE)
                    AND aila.amount <> 0
             UNION ALL                                                   --AWT
             SELECT pv.SEGMENT1 vendor_num,
                    pvsa.VENDOR_SITE_CODE,
                    pv.vendor_name vendor_name,
                    pha.segment1 po_number,
                    aila.gl_date,
                    aila.inventory_item_id,
                    aila.po_header_id,
                    aia.wfapproval_status invoice_status,
                    aia.doc_sequence_value vouchar,
                    DECODE (aila.pay_awt_group_name,
                            NULL, aila.awt_group_name,
                            aila.pay_awt_group_name)
                       wht_group,
                    aia.EXCHANGE_RATE,
                    aia.INVOICE_CURRENCY_CODE,
                    aila.line_type_lookup_code,
                    aia.invoice_id,
                    NULL invoice_payment_id,
                    aia.vendor_id,
                    aia.invoice_type_lookup_code,
                    NULL AS check_number,
                    aia.invoice_num,
                    aia.description,
                    aia.invoice_date,
                    NULL AS CHECK_DATE,
                    aila.amount invoice_amount,
                    DECODE (
                       invoice_type_lookup_code,
                       'AWT', DECODE (
                                 AMOUNT_APPLICABLE_TO_DISCOUNT,
                                 0, DECODE (
                                       AIA.INVOICE_CURRENCY_CODE,
                                       'PKR', ABS (aila.amount),
                                       (AIA.EXCHANGE_RATE * ABS (aila.amount)))))
                       DR,
                    DECODE (
                       invoice_type_lookup_code,
                       'AWT', DECODE (
                                 AMOUNT_APPLICABLE_TO_DISCOUNT,
                                 0, 0,
                                 DECODE (
                                    LINE_TYPE_LOOKUP_CODE,
                                    'AWT', 0,
                                    DECODE (
                                       AIA.INVOICE_CURRENCY_CODE,
                                       'PKR', ABS (aila.amount),
                                       (AIA.EXCHANGE_RATE * ABS (aila.amount))))))
                       CR,
                    DECODE (
                       invoice_type_lookup_code,
                       'AWT', DECODE (
                                 AMOUNT_APPLICABLE_TO_DISCOUNT,
                                 0, DECODE (AIA.INVOICE_CURRENCY_CODE,
                                            'PKR', 0,
                                            ABS (aila.amount))))
                       DR_FC,
                    DECODE (
                       invoice_type_lookup_code,
                       'AWT', DECODE (
                                 AMOUNT_APPLICABLE_TO_DISCOUNT,
                                 0, 0,
                                 DECODE (
                                    LINE_TYPE_LOOKUP_CODE,
                                    'AWT', 0,
                                    DECODE (AIA.INVOICE_CURRENCY_CODE,
                                            'PKR', 0,
                                            ABS (aila.amount)))))
                       CR_FC,
                    DECODE (cancelled_date, NULL, 'N', 'Y') cancelled,
                    'A' tag,
                    NULL OP_CR,
                    NULL OP_DR,
                    aia.org_id,
                    aia.SET_OF_BOOKS_ID,
                    'Opening Balance' AS opn_bal,
                    NULL un_invoiced,
                    PVSA.VENDOR_SITE_ID,
                    NULL AS ACC_DATE
               FROM ap_invoices_all aia,
                    ap_invoice_lines_v aila,
                    po_vendors pv,
                    Po_vendor_sites_all pvsa,
                    po_headers_all pha
              WHERE     invoice_type_lookup_code IN ('AWT')
                    AND aila.invoice_id = aia.invoice_id
                    AND (   aia.PAY_GROUP_LOOKUP_CODE NOT IN
                               ('RETENTION_MONEY', 'SECURITY_DEPOSIT')
                         OR aia.PAY_GROUP_LOOKUP_CODE IS NULL)
                    AND pv.vendor_id = aia.vendor_id
                    AND pv.VENDOR_ID = pvsa.VENDOR_ID
                    AND pvsa.VENDOR_SITE_ID = aia.VENDOR_SITE_ID
                    AND pha.po_header_id(+) = aila.po_header_id
                    AND aila.LINE_TYPE_LOOKUP_CODE NOT IN ('PREPAY')
                    AND aila.VALIDATION_STATUS IN
                           ('APPROVED', 'NEEDS REAPPROVAL')
                    AND aila.cancelled_flag = 'N'
                    --  and aia.vendor_id  = nvl(:p_vendor_id,aia.vendor_id)
                    --   and pvsa.VENDOR_SITE_ID = nvl(:P_VENDOR_SITE_ID,pvsa.VENDOR_SITE_ID)
                    --  AND TRUNC(aila.gl_date) BETWEEN :p_date_from AND :CP_GL_TO_DATE
                    --  and aia.org_id=nvl(:p_org_id,aia.org_id)

                    --   AND aia.SET_OF_BOOKS_ID = nvl(:p_legder,aia.SET_OF_BOOKS_ID)
                    --   and (pv.VENDOR_TYPE_LOOKUP_CODE = nvl(:p_vendor_type,VENDOR_TYPE_LOOKUP_CODE) OR pv.VENDOR_TYPE_LOOKUP_CODE IS NULL)
                    --   and aia.INVOICE_TYPE_LOOKUP_CODE = nvl(:p_INVOICE_TYPE,aia.INVOICE_TYPE_LOOKUP_CODE)
                    AND (cancelled_date IS NULL OR cancelled_date > SYSDATE)
                    AND aila.amount <> 0
             --Commented on 2-Feb-24
             /*  UNION ALL--PREPAYMENT
                select pv.SEGMENT1 vendor_num, pvsa.VENDOR_SITE_CODE, pv.vendor_name vendor_name, pha.segment1 po_number, aila.gl_date,
                        aila.inventory_item_id, aila.po_header_id,
                        aia.wfapproval_status invoice_status, aia.doc_sequence_value vouchar,
                        DECODE (aila.pay_awt_group_name,NULL, aila.awt_group_name,aila.pay_awt_group_name) wht_group,aia.EXCHANGE_RATE,aia.INVOICE_CURRENCY_CODE,
                        aila.line_type_lookup_code, aia.invoice_id, NULL invoice_payment_id,aia.vendor_id, aia.invoice_type_lookup_code, NULL AS check_number, aia.invoice_num,
                        'Prepayment Application' as description, aia.invoice_date,NULL AS CHECK_DATE,aila.amount invoice_amount,
                       DECODE(invoice_type_lookup_code,'STANDARD',decode(LINE_TYPE_LOOKUP_CODE,'AWT',0,decode(AIA.INVOICE_CURRENCY_CODE,'PKR',abs(aila.amount),(AIA.EXCHANGE_RATE * abs(aila.amount))))
                       ,'AWT',decode(LINE_TYPE_LOOKUP_CODE,'AWT',0,decode(AIA.INVOICE_CURRENCY_CODE,'PKR',abs(aila.amount),(AIA.EXCHANGE_RATE * abs(aila.amount))))) DR,
                        DECODE(invoice_type_lookup_code,'STANDARD',decode(LINE_TYPE_LOOKUP_CODE,'AWT',0,decode(AIA.INVOICE_CURRENCY_CODE,'PKR',abs(aila.amount),(AIA.EXCHANGE_RATE * abs(aila.amount))))
                        ,'AWT',decode(LINE_TYPE_LOOKUP_CODE,'AWT',0,decode(AIA.INVOICE_CURRENCY_CODE,'PKR',abs(aila.amount),(AIA.EXCHANGE_RATE * abs(aila.amount))))) CR,
                        DECODE(invoice_type_lookup_code,'STANDARD',decode(LINE_TYPE_LOOKUP_CODE,'AWT',0,decode(AIA.INVOICE_CURRENCY_CODE,'PKR',0,(abs(aila.amount))))
                         ,'AWT',decode(LINE_TYPE_LOOKUP_CODE,'AWT',0,decode(AIA.INVOICE_CURRENCY_CODE,'PKR',0,(abs(aila.amount))))) DR_FC,
                       DECODE(invoice_type_lookup_code,'STANDARD',decode(LINE_TYPE_LOOKUP_CODE,'AWT',0,decode(AIA.INVOICE_CURRENCY_CODE,'PKR',0,(abs(aila.amount))))
                       ,'AWT',decode(LINE_TYPE_LOOKUP_CODE,'AWT',0,decode(AIA.INVOICE_CURRENCY_CODE,'PKR',0,(abs(aila.amount))))) CR_FC,
                       DECODE (cancelled_date,NULL, 'N', 'Y') cancelled, 'A' tag,
                       NULL OP_CR,
                       NULL OP_DR,
                       aia.org_id,  aia.SET_OF_BOOKS_ID,
                       'Opening Balance' as opn_bal,NULL un_invoiced,PVSA.VENDOR_SITE_ID,null as ACC_DATE
                from ap_invoices_all aia,ap_invoice_lines_v aila,po_vendors pv,po_vendor_sites_all pvsa, po_headers_all pha
                where  invoice_type_lookup_code in ('STANDARD', 'CREDIT','PREPAYMENT','AWT')
                AND aila.invoice_id = aia.invoice_id
                and (aia.PAY_GROUP_LOOKUP_CODE not in ('RETENTION_MONEY','SECURITY_DEPOSIT') or aia.PAY_GROUP_LOOKUP_CODE is null)
                and pv.vendor_id = aia.vendor_id
                AND pha.po_header_id(+) = aila.po_header_id
                and aila.LINE_TYPE_LOOKUP_CODE  in ('PREPAY')
                AND aila.cancelled_flag = 'N'
                and pv.VENDOR_ID = pvsa.VENDOR_ID
                AND aila.VALIDATION_STATUS in ('APPROVED','NEEDS REAPPROVAL')
                and pvsa.VENDOR_SITE_ID = aia.VENDOR_SITE_ID
              --  and pvsa.VENDOR_SITE_ID = nvl(:P_VENDOR_SITE_ID,pvsa.VENDOR_SITE_ID)
              --  and aia.vendor_id  = nvl(:p_vendor_id,aia.vendor_id)
               -- AND TRUNC(aila.gl_date) BETWEEN :p_date_from AND :CP_GL_TO_DATE
              --  and aia.org_id=nvl(:p_org_id,aia.org_id)

              --  AND aia.SET_OF_BOOKS_ID = nvl(:p_legder,aia.SET_OF_BOOKS_ID)
              --  and (pv.VENDOR_TYPE_LOOKUP_CODE = nvl(:p_vendor_type,VENDOR_TYPE_LOOKUP_CODE) OR pv.VENDOR_TYPE_LOOKUP_CODE IS NULL)
              --  and aia.INVOICE_TYPE_LOOKUP_CODE = nvl(:p_INVOICE_TYPE,aia.INVOICE_TYPE_LOOKUP_CODE)
                and (cancelled_date is null or cancelled_date > sysdate)
                        and aila.amount <> 0
        */
             UNION ALL                                              --payments
               SELECT pv.SEGMENT1 vendor_num,
                      pvsa.VENDOR_SITE_CODE,
                      pv.vendor_name vendor_name,
                      NULL po_number,
                      aipa.ACCOUNTING_DATE gl_date,
                      NULL inventory_item_id,
                      NULL po_header_id,
                      aia.wfapproval_status invoice_status,
                      aca.doc_sequence_value vouchar,
                      NULL wht_group,
                      aia.EXCHANGE_RATE,
                      aia.INVOICE_CURRENCY_CODE,
                      NULL line_type_lookup_code,
                      aia.invoice_id,
                      aipa.invoice_payment_id,
                      aia.vendor_id,
                      DECODE (aia.invoice_type_lookup_code,
                              'PREPAYMENT', 'PREPAYMENT',
                              'DEBIT', 'DEBIT',
                              'PAYMENT')
                         invoice_type_lookup_code,
                      TO_CHAR (aca.check_number) check_number,
                      invoice_num,
                      DECODE (aia.invoice_type_lookup_code,
                              'PREPAYMENT', aia.description,
                              'DEBIT', aia.description,
                              NULL)
                         description,
                      aipa.accounting_date invoice_date,
                      ACA.CHECK_DATE,
                      aipa.amount,
                      (ABS (
                          NVL (
                             DECODE (
                                SIGN (aipa.amount),
                                1, (DECODE (AIA.INVOICE_CURRENCY_CODE,
                                            'PKR', aipa.amount,
                                            (aia.EXCHANGE_RATE * aipa.amount)))),
                             0)))
                         DR,
                      (ABS (
                          NVL (
                             DECODE (
                                SIGN (aipa.amount),
                                -1, (DECODE (AIA.INVOICE_CURRENCY_CODE,
                                             'PKR', aipa.amount,
                                             (aia.EXCHANGE_RATE * aipa.amount)))),
                             0)))
                         CR,
                      (ABS (
                          NVL (
                             DECODE (
                                SIGN (aipa.amount),
                                1, (DECODE (AIA.INVOICE_CURRENCY_CODE,
                                            'PKR', 0,
                                            (aipa.amount)))),
                             0)))
                         DR_FC,
                      (ABS (
                          NVL (
                             DECODE (
                                SIGN (aipa.amount),
                                -1, (DECODE (AIA.INVOICE_CURRENCY_CODE,
                                             'PKR', 0,
                                             (aipa.amount)))),
                             0)))
                         CR_FC,
                      reversal_flag,
                      'B' tag,
                      NULL OP_CR,
                      NULL OP_DR,
                      aia.org_id,
                      aia.SET_OF_BOOKS_ID,
                      'Opening Balance' AS opn_bal,
                      NULL un_invoiced,
                      PVSA.VENDOR_SITE_ID,
                      NULL AS ACC_DATE
                 FROM ap_invoice_payments_all aipa,
                      ap_invoices_all aia,
                      ap_invoice_lines_v aila,
                      ap_checks_all aca,
                      po_vendors pv,
                      po_vendor_sites_all pvsa
                WHERE     aia.invoice_id = aipa.invoice_id
                      AND aila.invoice_id = aia.invoice_id
                      AND aila.LINE_TYPE_LOOKUP_CODE IN
                             ('ITEM', 'MISCELLANEOUS', 'FREIGHT')
                      AND invoice_type_lookup_code NOT IN ('DEBIT', 'CREDIT')
                      AND aca.check_id = aipa.check_id
                      AND pv.vendor_id = aia.vendor_id
                      AND aila.cancelled_flag = 'N'
                      AND REVERSAL_INV_PMT_ID IS NULL
                      AND aila.VALIDATION_STATUS IN
                             ('APPROVED', 'NEEDS REAPPROVAL')
                      AND aca.BANK_ACCOUNT_NAME <> 'Freight Payment'
                      AND aipa.amount <> 0
                      AND aila.amount <> 0
                      AND pv.VENDOR_ID = pvsa.VENDOR_ID
                      AND pvsa.VENDOR_SITE_ID = aia.VENDOR_SITE_ID
                      --  and pvsa.VENDOR_SITE_ID = nvl(:P_VENDOR_SITE_ID,pvsa.VENDOR_SITE_ID)
                      --  AND aia.SET_OF_BOOKS_ID = nvl(:p_legder,aia.SET_OF_BOOKS_ID)
                      -- and (pv.VENDOR_TYPE_LOOKUP_CODE = nvl(:p_vendor_type,VENDOR_TYPE_LOOKUP_CODE) OR pv.VENDOR_TYPE_LOOKUP_CODE IS NULL)
                      -- and aia.vendor_id  = nvl(:p_vendor_id,aia.vendor_id)
                      -- AND TRUNC(aipa.accounting_date)  BETWEEN :p_date_from AND :CP_GL_TO_DATE
                      AND (cancelled_date IS NULL OR cancelled_date > SYSDATE)
             -- and aia.INVOICE_TYPE_LOOKUP_CODE = nvl(:p_INVOICE_TYPE,aia.INVOICE_TYPE_LOOKUP_CODE)
             -- and aia.org_id=nvl(:p_org_id,aia.org_id)
             -- and ((aia.PAY_GROUP_LOOKUP_CODE not in ('PERMANENT_ADVANCE') or aia.PAY_GROUP_LOOKUP_CODE is null
             -- or aia.INVOICE_TYPE_LOOKUP_CODE = 'PREPAYMENT' and aia.EARLIEST_SETTLEMENT_DATE is not null))
             GROUP BY aia.SET_OF_BOOKS_ID,
                      pv.vendor_name,
                      aipa.ACCOUNTING_DATE,
                      aia.wfapproval_status,
                      aca.doc_sequence_value,
                      aia.EXCHANGE_RATE,
                      aia.INVOICE_CURRENCY_CODE,
                      aia.invoice_id,
                      aipa.invoice_payment_id,
                      aia.vendor_id,
                      PVSA.VENDOR_SITE_ID,
                      aia.invoice_type_lookup_code,
                      aca.check_number,
                      invoice_num,
                      aia.invoice_type_lookup_code,
                      aipa.accounting_date,
                      ACA.CHECK_DATE,
                      aipa.amount,
                      reversal_flag,
                      aia.org_id,
                      aia.description,
                      pv.SEGMENT1,
                      pvsa.VENDOR_SITE_CODE
             UNION ALL                        --payments debit and credit memo
               SELECT pv.SEGMENT1 vendor_num,
                      pvsa.VENDOR_SITE_CODE,
                      pv.vendor_name vendor_name,
                      pha.segment1 po_number,
                      aipa.ACCOUNTING_DATE gl_date,
                      NULL inventory_item_id,
                      NULL po_header_id,
                      aia.wfapproval_status invoice_status,
                      aia.doc_sequence_value vouchar,
                      NULL wht_group,
                      aia.EXCHANGE_RATE,
                      aia.INVOICE_CURRENCY_CODE,
                      NULL line_type_lookup_code,
                      aia.invoice_id,
                      aipa.invoice_payment_id,
                      aia.vendor_id,
                      'PAYMENT' invoice_type_lookup_code,
                      TO_CHAR (aca.check_number) check_number,
                      invoice_num,
                      DECODE (aia.invoice_type_lookup_code,
                              'PREPAYMENT', aia.description,
                              'DEBIT', aia.description,
                              NULL)
                         description,
                      aipa.accounting_date invoice_date,
                      ACA.CHECK_DATE,
                      aipa.amount,
                      NULL DR,
                      (ABS (
                          NVL (
                             DECODE (
                                aia.invoice_type_lookup_code,
                                'PREPAYMENT', ABS (
                                                 (DECODE (
                                                     AIA.INVOICE_CURRENCY_CODE,
                                                     'PKR', aipa.amount,
                                                     (  aia.EXCHANGE_RATE
                                                      * aipa.amount)))),
                                'DEBIT', ABS (
                                            (DECODE (
                                                AIA.INVOICE_CURRENCY_CODE,
                                                'PKR', aipa.amount,
                                                (aia.EXCHANGE_RATE * aipa.amount)))),
                                (DECODE (AIA.INVOICE_CURRENCY_CODE,
                                         'PKR', aipa.amount,
                                         (aia.EXCHANGE_RATE * aipa.amount)))),
                             0)))
                         CR,
                      NULL DR_FC,
                      (ABS (
                          NVL (
                             DECODE (
                                aia.invoice_type_lookup_code,
                                'PREPAYMENT', ABS (
                                                 (DECODE (
                                                     AIA.INVOICE_CURRENCY_CODE,
                                                     'PKR', 0,
                                                     (aipa.amount)))),
                                'DEBIT', ABS (
                                            (DECODE (AIA.INVOICE_CURRENCY_CODE,
                                                     'PKR', 0,
                                                     (aipa.amount)))),
                                (DECODE (AIA.INVOICE_CURRENCY_CODE,
                                         'PKR', 0,
                                         (aipa.amount)))),
                             0)))
                         CR_FC,
                      reversal_flag,
                      'B' tag,
                      NULL OP_CR,
                      NULL OP_DR,
                      aia.org_id,
                      aia.SET_OF_BOOKS_ID,
                      'Opening Balance' AS opn_bal,
                      NULL un_invoiced,
                      PVSA.VENDOR_SITE_ID,
                      NULL AS ACC_DATE
                 FROM ap_invoice_payments_all aipa,
                      ap_invoices_all aia,
                      ap_invoice_lines_v aila,
                      ap_checks_all aca,
                      po_vendors pv,
                      po_vendor_sites_all pvsa,
                      po_headers_all pha
                WHERE     aia.invoice_id = aipa.invoice_id
                      AND aila.invoice_id = aia.invoice_id
                      AND invoice_type_lookup_code IN ('DEBIT', 'CREDIT')
                      AND aca.check_id = aipa.check_id
                      AND pv.vendor_id = aia.vendor_id
                      AND aila.cancelled_flag = 'N'
                      AND REVERSAL_INV_PMT_ID IS NULL
                      AND aipa.amount <> 0
                      AND aila.amount <> 0
                      AND aila.VALIDATION_STATUS IN
                             ('APPROVED', 'NEEDS REAPPROVAL')
                      AND pv.VENDOR_ID = pvsa.VENDOR_ID
                      AND pvsa.VENDOR_SITE_ID = aia.VENDOR_SITE_ID
                      -- and pvsa.VENDOR_SITE_ID = nvl(:P_VENDOR_SITE_ID,pvsa.VENDOR_SITE_ID)
                      AND pha.po_header_id(+) = aila.po_header_id
                      --AND aia.SET_OF_BOOKS_ID = nvl(:p_legder,aia.SET_OF_BOOKS_ID)
                      --and (pv.VENDOR_TYPE_LOOKUP_CODE = nvl(:p_vendor_type,VENDOR_TYPE_LOOKUP_CODE) OR pv.VENDOR_TYPE_LOOKUP_CODE IS NULL)
                      -- and aia.vendor_id  = nvl(:p_vendor_id,aia.vendor_id)
                      -- AND TRUNC(aipa.accounting_date)  BETWEEN :p_date_from AND :CP_GL_TO_DATE
                      AND (cancelled_date IS NULL OR cancelled_date > SYSDATE)
                      --  and aia.INVOICE_TYPE_LOOKUP_CODE = nvl(:p_INVOICE_TYPE,aia.INVOICE_TYPE_LOOKUP_CODE)
                      AND (   aia.PAY_GROUP_LOOKUP_CODE NOT IN
                                 ('PERMANENT_ADVANCE')
                           OR aia.PAY_GROUP_LOOKUP_CODE IS NULL)
             -- and aia.org_id=nvl(:p_org_id,aia.org_id)
             GROUP BY aia.SET_OF_BOOKS_ID,
                      pv.vendor_name,
                      pha.segment1,
                      aipa.ACCOUNTING_DATE,
                      aia.wfapproval_status,
                      aia.doc_sequence_value,
                      aia.EXCHANGE_RATE,
                      aia.INVOICE_CURRENCY_CODE,
                      aia.invoice_id,
                      aipa.invoice_payment_id,
                      aia.vendor_id,
                      PVSA.VENDOR_SITE_ID,
                      aia.invoice_type_lookup_code,
                      aca.check_number,
                      invoice_num,
                      aia.invoice_type_lookup_code,
                      aipa.accounting_date,
                      ACA.CHECK_DATE,
                      aipa.amount,
                      reversal_flag,
                      aia.org_id,
                      aia.description,
                      pv.SEGMENT1,
                      pvsa.VENDOR_SITE_CODE
             UNION ALL                                         --void payments
               SELECT pv.SEGMENT1 vendor_num,
                      pvsa.VENDOR_SITE_CODE,
                      pv.vendor_name vendor_name,
                      NULL AS po_number,
                      aipa.ACCOUNTING_DATE gl_date,
                      NULL inventory_item_id,
                      NULL po_header_id,
                      aia.wfapproval_status invoice_status,
                      aia.doc_sequence_value vouchar,
                      NULL wht_group,
                      aia.EXCHANGE_RATE,
                      aia.INVOICE_CURRENCY_CODE,
                      NULL line_type_lookup_code,
                      aia.invoice_id,
                      aipa.invoice_payment_id,
                      aia.vendor_id,
                      DECODE (aia.invoice_type_lookup_code,
                              'PREPAYMENT', 'PREPAYMENT',
                              'DEBIT', 'DEBIT',
                              'PAYMENT')
                         invoice_type_lookup_code,
                      TO_CHAR (aca.check_number) check_number,
                      invoice_num,
                      'Void Payment' description,
                      aipa.accounting_date invoice_date,
                      ACA.CHECK_DATE,
                      aipa.amount,
                      (ABS (
                          NVL (
                             DECODE (
                                aia.invoice_type_lookup_code,
                                'DEBIT', ABS (
                                            (DECODE (
                                                AIA.INVOICE_CURRENCY_CODE,
                                                'PKR', aipa.amount,
                                                (aia.EXCHANGE_RATE * aipa.amount)))),
                                'AWT', DECODE (
                                          SIGN (aipa.AMOUNT),
                                          1, ABS (
                                                (DECODE (
                                                    aia.invoice_currency_code,
                                                    'PKR', aipa.amount,
                                                    (  aia.exchange_rate
                                                     * aipa.amount))))),
                                'CREDIT', ABS (
                                             (DECODE (
                                                 AIA.INVOICE_CURRENCY_CODE,
                                                 'PKR', aipa.amount,
                                                 (aia.EXCHANGE_RATE * aipa.amount)))),
                                'STANDARD', DECODE (
                                               SIGN (aipa.AMOUNT),
                                               1, ABS (
                                                     (DECODE (
                                                         aia.invoice_currency_code,
                                                         'PKR', aipa.amount,
                                                         (  aia.exchange_rate
                                                          * aipa.amount)))))),
                             0)))
                         DR,
                      (ABS (
                          NVL (
                             DECODE (
                                aia.invoice_type_lookup_code,
                                'DEBIT', 0,
                                'CREDIT', 0,
                                'AWT', DECODE (
                                          SIGN (aipa.AMOUNT),
                                          -1, ABS (
                                                 (DECODE (
                                                     aia.invoice_currency_code,
                                                     'PKR', aipa.amount,
                                                     (  aia.exchange_rate
                                                      * aipa.amount))))),
                                'PREPAYMENT', ABS (
                                                 (DECODE (
                                                     AIA.INVOICE_CURRENCY_CODE,
                                                     'PKR', aipa.amount,
                                                     (  aia.EXCHANGE_RATE
                                                      * aipa.amount)))),
                                'STANDARD', DECODE (
                                               SIGN (aipa.AMOUNT),
                                               -1, ABS (
                                                      (DECODE (
                                                          aia.invoice_currency_code,
                                                          'PKR', aipa.amount,
                                                          (  aia.exchange_rate
                                                           * aipa.amount))))),
                                (DECODE (AIA.INVOICE_CURRENCY_CODE,
                                         'PKR', aipa.amount,
                                         (aia.EXCHANGE_RATE * aipa.amount)))),
                             0)))
                         CR,
                      (ABS (
                          NVL (
                             DECODE (
                                aia.invoice_type_lookup_code,
                                'DEBIT', ABS (
                                            (DECODE (AIA.INVOICE_CURRENCY_CODE,
                                                     'PKR', 0,
                                                     (aipa.amount)))),
                                'CREDIT', ABS (
                                             (DECODE (AIA.INVOICE_CURRENCY_CODE,
                                                      'PKR', 0,
                                                      (aipa.amount))))),
                             0)))
                         DR_FC,
                      (ABS (
                          NVL (
                             DECODE (
                                aia.invoice_type_lookup_code,
                                'DEBIT', 0,
                                'CREDIT', 0,
                                'PREPAYMENT', ABS (
                                                 (DECODE (
                                                     AIA.INVOICE_CURRENCY_CODE,
                                                     'PKR', 0,
                                                     (aipa.amount)))),
                                (DECODE (AIA.INVOICE_CURRENCY_CODE,
                                         'PKR', 0,
                                         (aipa.amount)))),
                             0)))
                         CR_FC,
                      reversal_flag,
                      'B' tag,
                      NULL OP_CR,
                      NULL OP_DR,
                      aia.org_id,
                      aia.SET_OF_BOOKS_ID,
                      'Opening Balance' AS opn_bal,
                      NULL un_invoiced,
                      PVSA.VENDOR_SITE_ID,
                      NULL AS ACC_DATE
                 FROM ap_invoice_payments_all aipa,
                      ap_invoices_all aia,
                      ap_invoice_lines_v aila,
                      ap_checks_all aca,
                      po_vendors pv,
                      po_vendor_sites_all pvsa,
                      po_headers_all pha
                WHERE     aia.invoice_id = aipa.invoice_id
                      AND aila.invoice_id = aia.invoice_id
                      AND aila.LINE_TYPE_LOOKUP_CODE IN ('ITEM', 'MISCELLANEOUS')
                      AND aca.check_id = aipa.check_id
                      AND pv.vendor_id = aia.vendor_id
                      AND aila.cancelled_flag = 'N'
                      AND aipa.amount <> 0
                      AND aila.amount <> 0
                      AND pv.VENDOR_ID = pvsa.VENDOR_ID
                      AND aila.VALIDATION_STATUS IN
                             ('APPROVED', 'NEEDS REAPPROVAL')
                      AND pvsa.VENDOR_SITE_ID = aia.VENDOR_SITE_ID
                      -- and pvsa.VENDOR_SITE_ID = nvl(:P_VENDOR_SITE_ID,pvsa.VENDOR_SITE_ID)
                      AND pha.po_header_id(+) = aila.po_header_id
                      --AND aia.SET_OF_BOOKS_ID = nvl(:p_legder,aia.SET_OF_BOOKS_ID)
                      -- and (pv.VENDOR_TYPE_LOOKUP_CODE = nvl(:p_vendor_type,VENDOR_TYPE_LOOKUP_CODE) OR pv.VENDOR_TYPE_LOOKUP_CODE IS NULL)
                      -- and aia.vendor_id  = nvl(:p_vendor_id,aia.vendor_id)
                      -- AND TRUNC(aipa.ACCOUNTING_DATE)  BETWEEN :p_date_from AND :CP_GL_TO_DATE
                      AND (cancelled_date IS NULL OR cancelled_date > SYSDATE)
                      -- and aia.INVOICE_TYPE_LOOKUP_CODE = nvl(:p_INVOICE_TYPE,aia.INVOICE_TYPE_LOOKUP_CODE)
                      AND ( (   aia.PAY_GROUP_LOOKUP_CODE NOT IN
                                   ('PERMANENT_ADVANCE')
                             OR aia.PAY_GROUP_LOOKUP_CODE IS NULL
                             OR     aia.INVOICE_TYPE_LOOKUP_CODE = 'PREPAYMENT'
                                AND aia.EARLIEST_SETTLEMENT_DATE IS NOT NULL))
                      -- and aia.org_id=nvl(:p_org_id,aia.org_id)
                      AND REVERSAL_INV_PMT_ID IS NOT NULL
                      AND aipa.BANK_ACCOUNT_NUM IS NULL
                      AND aipa.invoice_id IN
                             (                                      --payments
                              SELECT   aia.invoice_id
                                  FROM ap_invoice_payments_all aipa,
                                       ap_invoices_all aia,
                                       ap_invoice_lines_v aila,
                                       ap_checks_all aca,
                                       po_vendors pv,
                                       po_headers_all pha
                                 WHERE     aia.invoice_id = aipa.invoice_id
                                       AND aila.invoice_id = aia.invoice_id
                                       AND aila.LINE_TYPE_LOOKUP_CODE IN
                                              ('ITEM', 'MISCELLANEOUS')
                                       AND aca.check_id = aipa.check_id
                                       AND pv.vendor_id = aia.vendor_id
                                       AND aila.cancelled_flag = 'N'
                                       AND aipa.amount <> 0
                                       AND aila.amount <> 0
                                       AND pha.po_header_id(+) = aila.po_header_id
                                       -- AND aia.SET_OF_BOOKS_ID = nvl(:p_legder,aia.SET_OF_BOOKS_ID)
                                       --  and (pv.VENDOR_TYPE_LOOKUP_CODE = nvl(:p_vendor_type,VENDOR_TYPE_LOOKUP_CODE) OR pv.VENDOR_TYPE_LOOKUP_CODE IS NULL)
                                       -- and aia.vendor_id  = nvl(:p_vendor_id,aia.vendor_id)
                                       -- AND TRUNC(aipa.ACCOUNTING_DATE)  BETWEEN :p_date_from AND :CP_GL_TO_DATE
                                       AND (   cancelled_date IS NULL
                                            OR cancelled_date > SYSDATE)
                                       --and aia.INVOICE_TYPE_LOOKUP_CODE = nvl(:p_INVOICE_TYPE,aia.INVOICE_TYPE_LOOKUP_CODE)
                                       AND ( (   aia.PAY_GROUP_LOOKUP_CODE NOT IN
                                                    ('PERMANENT_ADVANCE')
                                              OR aia.PAY_GROUP_LOOKUP_CODE IS NULL
                                              OR     aia.INVOICE_TYPE_LOOKUP_CODE =
                                                        'PREPAYMENT'
                                                 AND aia.EARLIEST_SETTLEMENT_DATE
                                                        IS NOT NULL))
                              GROUP BY pv.vendor_name,
                                       aipa.ACCOUNTING_DATE,
                                       aia.wfapproval_status,
                                       aia.doc_sequence_value,
                                       aia.EXCHANGE_RATE,
                                       aia.INVOICE_CURRENCY_CODE,
                                       aia.invoice_id,
                                       aipa.invoice_payment_id,
                                       aia.vendor_id,
                                       aia.invoice_type_lookup_code,
                                       aca.check_number,
                                       invoice_num,
                                       aia.invoice_type_lookup_code,
                                       aipa.accounting_date,
                                       ACA.CHECK_DATE,
                                       aipa.amount,
                                       reversal_flag,
                                       aia.org_id,
                                       aia.description)
             GROUP BY aia.SET_OF_BOOKS_ID,
                      pv.vendor_name,
                      aipa.ACCOUNTING_DATE,
                      aia.wfapproval_status,
                      aia.doc_sequence_value,
                      aia.EXCHANGE_RATE,
                      aia.INVOICE_CURRENCY_CODE,
                      aia.invoice_id,
                      aipa.invoice_payment_id,
                      aia.vendor_id,
                      PVSA.VENDOR_SITE_ID,
                      aia.invoice_type_lookup_code,
                      aca.check_number,
                      invoice_num,
                      aia.invoice_type_lookup_code,
                      aipa.accounting_date,
                      ACA.CHECK_DATE,
                      aipa.amount,
                      reversal_flag,
                      aia.org_id,
                      aia.description,
                      pv.SEGMENT1,
                      pvsa.VENDOR_SITE_CODE
             UNION ALL
             --debit and credit memo
             SELECT pv.SEGMENT1 vendor_num,
                    pvsa.VENDOR_SITE_CODE,
                    pv.vendor_name vendor_name,
                    NULL po_number,
                    aia.gl_date,
                    NULL inventory_item_id,
                    NULL po_header_id,
                    aia.wfapproval_status invoice_status,
                    aia.doc_sequence_value vouchar,
                    NULL wht_group,
                    aia.EXCHANGE_RATE,
                    aia.INVOICE_CURRENCY_CODE,
                    NULL line_type_lookup_code,
                    aia.invoice_id,
                    NULL invoice_payment_id,
                    aia.vendor_id,
                    aia.invoice_type_lookup_code,
                    NULL check_number,
                    invoice_num,
                    DECODE (aia.invoice_type_lookup_code,
                            'PREPAYMENT', aia.description,
                            'DEBIT', aia.description,
                            NULL)
                       description,
                    aia.INVOICE_DATE invoice_date,
                    NULL CHECK_DATE,
                    aila.AMOUNT invoice_amount,
                    ABS (
                       NVL (
                          DECODE (
                             SIGN (AILA.AMOUNT),
                             -1, ABS (
                                    (DECODE (aia.INVOICE_CURRENCY_CODE,
                                             'PKR', AILA.AMOUNT,
                                             (aia.EXCHANGE_RATE * AILA.AMOUNT))))),
                          0))
                       DR,
                    ABS (
                       NVL (
                          DECODE (
                             SIGN (AILA.AMOUNT),
                             1, ABS (
                                   (DECODE (aia.INVOICE_CURRENCY_CODE,
                                            'PKR', AILA.AMOUNT,
                                            (aia.EXCHANGE_RATE * AILA.AMOUNT))))),
                          0))
                       CR,
                    ABS (
                       NVL (
                          DECODE (
                             SIGN (AILA.AMOUNT),
                             -1, ABS (
                                    (DECODE (aia.INVOICE_CURRENCY_CODE,
                                             'PKR', 0,
                                             (AILA.AMOUNT))))),
                          0))
                       DR_FC,
                    ABS (
                       NVL (
                          DECODE (
                             SIGN (AILA.AMOUNT),
                             1, ABS (
                                   (DECODE (aia.INVOICE_CURRENCY_CODE,
                                            'PKR', 0,
                                            (AILA.AMOUNT))))),
                          0))
                       CR_FC,
                    NULL reversal_flag,
                    'B' tag,
                    NULL OP_CR,
                    NULL OP_DR,
                    aia.org_id,
                    aia.SET_OF_BOOKS_ID,
                    'Opening Balance' AS opn_bal,
                    NULL un_invoiced,
                    PVSA.VENDOR_SITE_ID,
                    NULL AS ACC_DATE
               FROM ap_invoice_lines_v aila,
                    ap_invoices_all aia,
                    po_vendors pv,
                    po_vendor_sites_all pvsa
              WHERE     aila.invoice_id = aia.invoice_id
                    AND aila.LINE_TYPE_LOOKUP_CODE IN
                           ('ITEM', 'MISCELLANEOUS', 'AWT', 'TAX')
                    AND invoice_type_lookup_code IN ('DEBIT', 'CREDIT')
                    AND aila.VALIDATION_STATUS IN
                           ('APPROVED', 'NEEDS REAPPROVAL')
                    AND pv.vendor_id = aia.vendor_id
                    AND aila.cancelled_flag = 'N'
                    AND aila.AMOUNT <> 0
                    -- AND aia.SET_OF_BOOKS_ID = nvl(:p_legder,aia.SET_OF_BOOKS_ID)
                    AND pv.VENDOR_ID = pvsa.VENDOR_ID
                    AND pvsa.VENDOR_SITE_ID = aia.VENDOR_SITE_ID
                    -- and pvsa.VENDOR_SITE_ID = nvl(:P_VENDOR_SITE_ID,pvsa.VENDOR_SITE_ID)
                    -- and (pv.VENDOR_TYPE_LOOKUP_CODE = nvl(:p_vendor_type,VENDOR_TYPE_LOOKUP_CODE) OR pv.VENDOR_TYPE_LOOKUP_CODE IS NULL)
                    -- and aia.INVOICE_TYPE_LOOKUP_CODE = nvl(:p_INVOICE_TYPE,aia.INVOICE_TYPE_LOOKUP_CODE)
                    -- and aia.vendor_id  = nvl(:p_vendor_id,aia.vendor_id)
                    -- AND TRUNC(aia.gl_date)  BETWEEN :p_date_from AND :CP_GL_TO_DATE
                    AND (cancelled_date IS NULL OR cancelled_date > SYSDATE)
                    AND (   aia.PAY_GROUP_LOOKUP_CODE NOT IN
                               ('PERMANENT_ADVANCE', 'SECURITY_DEPOSIT')
                         OR aia.PAY_GROUP_LOOKUP_CODE IS NULL)
             -- and aia.org_id=nvl(:p_org_id,aia.org_id)


             UNION ALL
             SELECT pv.SEGMENT1 vendor_num,
                    pvsa.VENDOR_SITE_CODE,
                    pv.vendor_name vendor_name,
                    NULL AS po_number,
                    aida.ACCOUNTING_DATE gl_date,
                    NULL AS inventory_item_id,
                    aila.po_header_id,
                    aia.wfapproval_status invoice_status,
                    aia.doc_sequence_value vouchar,
                    NULL AS WHT_GROUP,
                    aia.EXCHANGE_RATE,
                    'PKR' AS INVOICE_CURRENCY_CODE,
                    aila.line_type_lookup_code,
                    aia.invoice_id,
                    NULL invoice_payment_id,
                    aia.vendor_id,
                    aia.invoice_type_lookup_code,
                    NULL AS check_number,
                    aia.invoice_num,
                    aia.description,
                    aia.invoice_date,
                    NULL AS CHECK_DATE,
                    aila.amount invoice_amount,
                    CASE
                       WHEN aida.AMOUNT < 0
                       THEN
                          ABS (aida.AMOUNT) * NVL (aia.EXCHANGE_RATE, 1)
                    END
                       AS dr,
                    CASE
                       WHEN aida.AMOUNT > 0
                       THEN
                          ABS (aida.AMOUNT) * NVL (aia.EXCHANGE_RATE, 1)
                    END
                       AS cr,
                    CASE
                       WHEN     aia.INVOICE_CURRENCY_CODE = 'PKR'
                            AND aida.AMOUNT < 0
                       THEN
                          0
                       WHEN     aia.INVOICE_CURRENCY_CODE <> 'PKR'
                            AND aida.AMOUNT < 0
                       THEN
                          ABS (aida.AMOUNT)
                    END
                       AS dr_fc,
                    CASE
                       WHEN     aia.INVOICE_CURRENCY_CODE = 'PKR'
                            AND aida.AMOUNT > 0
                       THEN
                          0
                       WHEN     aia.INVOICE_CURRENCY_CODE <> 'PKR'
                            AND aida.AMOUNT > 0
                       THEN
                          ABS (aida.AMOUNT)
                    END
                       AS cr_fc,
                    DECODE (cancelled_date, NULL, 'N', 'Y') cancelled,
                    'A' tag,
                    NULL OP_CR,
                    NULL OP_DR,
                    aia.org_id,
                    aia.SET_OF_BOOKS_ID,
                    'Opening Balance' AS opn_bal,
                    NULL un_invoiced,
                    pvsa.VENDOR_SITE_ID,
                    NULL AS ACC_DATE
               FROM po_vendors pv,
                    ap_invoices_all aia,
                    ap_invoice_lines_all aila,
                    ap_invoice_distributions_all aida,
                    Po_vendor_sites_all pvsa
              WHERE     aia.INVOICE_ID = aila.INVOICE_ID
                    AND aia.INVOICE_ID = aida.INVOICE_ID
                    AND aia.vendor_id = pv.VENDOR_ID
                    AND pv.VENDOR_ID = pvsa.VENDOR_ID
                    AND pvsa.VENDOR_SITE_ID = aia.VENDOR_SITE_ID
                    AND aila.LINE_NUMBER = aida.INVOICE_LINE_NUMBER
                    AND aia.invoice_type_lookup_code IN
                           ('STANDARD',
                            'CREDIT',
                            'PREPAYMENT',
                            'EXPENSE REPORT',
                            'AWT',
                            'DEBIT')
                    AND (   aia.PAY_GROUP_LOOKUP_CODE NOT IN
                               ('RETENTION_MONEY', 'SECURITY_DEPOSIT')
                         OR aia.PAY_GROUP_LOOKUP_CODE IS NULL)
                    AND aila.LINE_TYPE_LOOKUP_CODE IN
                           ('ITEM', 'TAX', 'FREIGHT', 'MISCELLANEOUS')
                    AND (aila.CANCELLED_FLAG = 'Y' OR aila.DISCARDED_FLAG = 'Y')
             --AND p_advance is null
             -- AND trunc(aida.ACCOUNTING_DATE) BETWEEN :p_date_from AND :CP_GL_TO_DATE
             -- and (pv.VENDOR_TYPE_LOOKUP_CODE = nvl(:p_vendor_type,VENDOR_TYPE_LOOKUP_CODE) OR pv.VENDOR_TYPE_LOOKUP_CODE IS NULL)
             -- and aia.VENDOR_SITE_ID = nvl(:P_VENDOR_SITE_ID,aia.VENDOR_SITE_ID)
             --  AND aia.SET_OF_BOOKS_ID = nvl(:p_legder,aia.SET_OF_BOOKS_ID)
             --  and aia.org_id=nvl(:p_org_id,aia.org_id)
             --  and aia.vendor_id  = nvl(:p_vendor_id,aia.vendor_id)
             --#########################Below Query will calculate Exchange Gain Los#####################
             UNION ALL
               SELECT pv.SEGMENT1 vendor_num,
                      pvsa.VENDOR_SITE_CODE,
                      pv.VENDOR_NAME,
                      NULL AS PO_NUMBER,
                      ai.GL_DATE,
                      NULL AS INVENTORY_ITEM_ID,
                      NULL AS PO_HEADER_ID,
                      NULL INVOICE_STATUS,
                      ai.DOC_SEQUENCE_VALUE VOUCHAR,
                      NULL WHT_GROUP,
                      NULL AS EXCHANGE_RATE,
                      'PKR' AS INVOICE_CURRENCY_CODE,
                      NULL AS LINE_TYPE_LOOKUP_CODE,
                      ai.INVOICE_ID,
                      NULL AS INVOICE_PAYMENT_ID,
                      ai.VENDOR_ID,
                      ai.INVOICE_TYPE_LOOKUP_CODE,
                      NULL AS CHECK_NUMBER,
                      ai.INVOICE_NUM,
                      'PREPAYMENT APPLICATION VARIANCE' DESCRIPTION,
                      ai.INVOICE_DATE,
                      NULL AS CHECK_DATE,
                      NULL AS INVOICE_AMOUNT,
                      SUM (xel.ACCOUNTED_CR) AS DR,
                      SUM (xel.ACCOUNTED_DR) AS CR,
                      NULL AS DR_FC,
                      NULL AS CR_FC,
                      NULL CANCELLED,
                      NULL AS TAG,
                      NULL AS OP_CR,
                      NULL AS OP_DR,
                      ai.ORG_ID,
                      ai.SET_OF_BOOKS_ID,
                      NULL AS OPN_BAL,
                      NULL AS UN_INVOICED,
                      pvsa.VENDOR_SITE_ID,
                      xel.ACCOUNTING_DATE AS ACC_DATE
                 FROM xla_ae_lines xel,
                      xla_ae_headers xeh,
                      ap_invoices_all ai,
                      xla.xla_transaction_entities xte,
                      po_vendors pv,
                      po_vendor_sites_all pvsa
                WHERE     xte.application_id = 200
                      AND xel.application_id = xeh.application_id
                      AND xte.application_id = xeh.application_id
                      AND pv.VENDOR_ID = pvsa.VENDOR_ID
                      AND pvsa.VENDOR_SITE_ID = ai.VENDOR_SITE_ID
                      AND xel.ae_header_id = xeh.ae_header_id
                      AND xte.entity_code = 'AP_INVOICES'
                      AND xte.source_id_int_1 = ai.invoice_id
                      AND xte.entity_id = xeh.entity_id
                      AND ai.VENDOR_ID = pv.VENDOR_ID
                      AND ai.invoice_type_lookup_code IN
                             ('STANDARD',
                              'CREDIT',
                              'PREPAYMENT',
                              'EXPENSE REPORT')
                      AND (   ai.PAY_GROUP_LOOKUP_CODE NOT IN
                                 ('RETENTION_MONEY', 'SECURITY_DEPOSIT')
                           OR ai.PAY_GROUP_LOOKUP_CODE IS NULL)
                      AND xel.ACCOUNTING_CLASS_CODE IN ('GAIN', 'LOSS') -- Get Exchange rate variance only
             --AND p_advance is null
             -- AND trunc(xel.ACCOUNTING_DATE)  BETWEEN :p_date_from AND :CP_GL_TO_DATE
             -- and (pv.VENDOR_TYPE_LOOKUP_CODE = nvl(:p_vendor_type,VENDOR_TYPE_LOOKUP_CODE) OR pv.VENDOR_TYPE_LOOKUP_CODE IS NULL)
             -- and ai.VENDOR_SITE_ID = nvl(:P_VENDOR_SITE_ID,ai.VENDOR_SITE_ID)
             -- AND ai.SET_OF_BOOKS_ID = nvl(:p_legder,ai.SET_OF_BOOKS_ID)
             -- and ai.org_id=nvl(:p_org_id,ai.org_id)
             -- and ai.vendor_id  = nvl(:p_vendor_id,ai.vendor_id)
             GROUP BY ai.SET_OF_BOOKS_ID,
                      pv.VENDOR_NAME,
                      ai.GL_DATE,
                      ai.DOC_SEQUENCE_VALUE,
                      ai.INVOICE_ID,
                      ai.VENDOR_ID,
                      ai.INVOICE_TYPE_LOOKUP_CODE,
                      ai.INVOICE_NUM,
                      ai.INVOICE_DATE,
                      ai.ORG_ID,
                      pvsa.VENDOR_SITE_ID,
                      xel.ACCOUNTING_DATE,
                      pv.SEGMENT1,
                      pvsa.VENDOR_SITE_CODE) A
      WHERE 1 = 1 AND NVL (A.cancelled, 'N') = 'N'
   --and  vendor_id  = nvl(:p_vendor_id,A.vendor_id) --in (select vendor_id from po_vendors where segment1 between vend_f and vend_t)
   --     and A.VENDOR_SITE_ID = nvl(:P_VENDOR_SITE_ID,A.VENDOR_SITE_ID)
   --      AND TRUNC(A.gl_date) BETWEEN :p_date_from AND :CP_GL_TO_DATE
   --       and A.org_id=nvl(:p_org_id,A.org_id)

   --     AND A.SET_OF_BOOKS_ID = nvl(:p_legder,A.SET_OF_BOOKS_ID)
   -- and (pv.VENDOR_TYPE_LOOKUP_CODE = nvl(:p_vendor_type,VENDOR_TYPE_LOOKUP_CODE) OR pv.VENDOR_TYPE_LOOKUP_CODE IS NULL)
   -- and aia.INVOICE_TYPE_LOOKUP_CODE = nvl(:p_INVOICE_TYPE,aia.INVOICE_TYPE_LOOKUP_CODE)
   --and :p_type = 'Summary'
   GROUP BY A.SET_OF_BOOKS_ID,
            A.org_id,
            vendor_num,
            A.VENDOR_ID,
            vendor_site_code,
            A.vendor_site_id,
            vendor_name,
            gl_date,
            vouchar,
            INVOICE_TYPE_LOOKUP_CODE,
            DESCRIPTION,
            INVOICE_NUM,
            INVOICE_CURRENCY_CODE,
            A.Invoice_ID ) --where vendor_id=14046