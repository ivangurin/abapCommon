class ZCL_COMMON_STATIC definition
  public
  final
  create public .

*"* public components of class ZCL_COMMON_STATIC
*"* do not include other source files here!!!
public section.

  constants CURRENCY_LOCAL type WAERS value 'RUB' ##NO_TEXT.
  constants CURRENCY_RUB type WAERS value 'RUB' ##NO_TEXT.
  constants CURRENCY_USD type WAERS value 'USD' ##NO_TEXT.
  constants CURRENCY_EUR type WAERS value 'EUR' ##NO_TEXT.
  constants LANGU_RU type LANGU value 'R' ##NO_TEXT.
  constants LANGU_EN type LANGU value 'E' ##NO_TEXT.
  constants COUNTRY_RU type LAND1 value 'RU' ##NO_TEXT.
  constants UNIT_ST type WAERS value 'ST' ##NO_TEXT.

  class-methods GET_COUNTRY_TEXT
    importing
      !I_COUNTRY type SIMPLE
    returning
      value(E_TEXT) type STRING .
  class-methods GET_COUNTRY_LIST
    returning
      value(ET_VALUES) type ZIVALUES .
  class-methods GET_COUNTRY_BY_CODE
    importing
      !I_CODE type SIMPLE
    returning
      value(E_COUNTRY) type LAND1 .
  class-methods GET_COUNTRY_BY_TEXT
    importing
      !I_TEXT type SIMPLE
    returning
      value(E_ID) type STRING .
  class-methods GET_REGION_LIST
    importing
      !I_COUNTRY type SIMPLE default 'RU'
      !I_LANGU type LANGU default SY-LANGU
    preferred parameter I_COUNTRY
    returning
      value(ET_LIST) type ZIVALUES .
  class-methods GET_REGION_TEXT
    importing
      !I_COUNTRY type SIMPLE default 'RU'
      !I_REGION type SIMPLE
      !I_LANGU type LANGU default SY-LANGU
    returning
      value(E_TEXT) type STRING
    raising
      ZCX_GENERIC .
  class-methods GET_REGION_VALUES
    importing
      !I_COUNTRY type SIMPLE
      !I_WITH_ID type ABAP_BOOL default ABAP_FALSE
    returning
      value(ET_VALUES) type ZIVALUES .
  class-methods GET_REGION_BY_TEXT
    importing
      !I_COUNTRY type SIMPLE
      !I_TEXT type SIMPLE
    returning
      value(E_ID) type STRING .
  class-methods GET_CATEGORY_TEXT
    importing
      !I_CATEGORY_ID type GUID
    returning
      value(E_TEXT) type STRING .
  class-methods GET_PRODUCT_TEXT
    importing
      !I_PRODUCT_ID type GUID
    returning
      value(E_TEXT) type STRING .
  class-methods GET_CURRENCY_TEXT
    importing
      !I_CURRENCY type WAERK
    returning
      value(E_TEXT) type STRING .
  class-methods GET_UNIT_TEXT
    importing
      !I_UNIT type SIMPLE
      !I_LANGU type LANGU default SY-LANGU
    returning
      value(E_TEXT) type STRING
    raising
      ZCX_GENERIC .
  class-methods GET_UNIT_ID_BY_TEXT
    importing
      !I_TEXT type SIMPLE
    returning
      value(E_ID) type STRING .
  class-methods GET_EXCHANGE_RATE
    importing
      !I_FROM type SIMPLE
      !I_TO type SIMPLE default CURRENCY_LOCAL
      !I_DATE type D default SY-DATUM
    returning
      value(E_RATE) type ZE_EXCHANGE_RATE
    raising
      ZCX_GENERIC .
  class-methods CONVERT_ISO2UNIT
    importing
      !I_ISO type SIMPLE
    returning
      value(E_UNIT) type MEINS .
  class-methods CONVERT_CURRENCY
    importing
      !I_FROM type SIMPLE default CURRENCY_LOCAL
      !I_TO type SIMPLE default CURRENCY_LOCAL
      !I_VALUE type SIMPLE
      !I_DATE type D default SY-DATUM
    returning
      value(E_VALUE) type ZE_VALUE
    raising
      ZCX_GENERIC .
  class-methods CONVERT_UNIT2OKEI
    importing
      !I_ID type SIMPLE
    returning
      value(E_ID) type STRING .
  class-methods IS_EMAIL_CORRECT
    importing
      !I_EMAIL type SIMPLE
    returning
      value(E_IS) type ABAP_BOOL .
  class-methods IS_PHONE_CORRECT
    importing
      !I_PHONE type SIMPLE
    returning
      value(R_CORRECT) type FLAG .
  class-methods IS_OGRN_CORRECT
    importing
      !I_OGRN type SIMPLE
    returning
      value(E_IS) type ABAP_BOOL .
  class-methods IS_INN_CORRECT
    importing
      !I_INN type SIMPLE
    returning
      value(E_IS) type ABAP_BOOL .
  class-methods IS_KPP_CORRECT
    importing
      !I_INN type SIMPLE
      !I_KPP type SIMPLE
    returning
      value(E_IS) type ABAP_BOOL .
  class-methods IS_OKPO_CORRECT
    importing
      !I_OKPO type SIMPLE
    returning
      value(E_IS) type ABAP_BOOL .
  class-methods IS_ACCOUNT_CORRECT
    importing
      !I_BIC type SIMPLE
      !I_ACCOUNT type SIMPLE
    returning
      value(E_IS) type ABAP_BOOL .
  protected section.
*"* protected components of class ZCL_COMMON_STATIC
*"* do not include other source files here!!!
  private section.

    class-methods scalar
      importing
        !i_v1  type simple
        !i_v2  type int4_table
      changing
        !c_res type i .
*"* private components of class ZCL_COMMON_STATIC
*"* do not include other source files here!!!
ENDCLASS.



CLASS ZCL_COMMON_STATIC IMPLEMENTATION.


  method convert_currency.

    check i_from  is not initial.
    check i_to    is not initial.

    if i_from eq i_to.
      e_value = i_value.
      return.
    endif.

    check i_value is not initial.
    check i_date  is not initial.

    data l_value type p length 16 decimals 5.
    l_value = i_value.

    if i_from ne currency_local.

      data l_foreign_factor type i.
      data l_local_factor type i.
      call function 'CONVERT_TO_LOCAL_CURRENCY'
        exporting
          date             = i_date
          foreign_amount   = l_value
          foreign_currency = i_from
          local_currency   = currency_local
        importing
          local_amount     = l_value
          foreign_factor   = l_foreign_factor
          local_factor     = l_local_factor
        exceptions
          no_rate_found    = 1
          overflow         = 2
          no_factors_found = 3
          no_spread_found  = 4
          derived_2_times  = 5
          others           = 6.
      if sy-subrc ne 0.
        zcx_generic=>raise( ).
      endif.

      l_value = l_value * l_local_factor / l_foreign_factor.

    endif.

    if i_to ne currency_local.

      clear l_foreign_factor.
      clear l_local_factor.
      call function 'CONVERT_TO_FOREIGN_CURRENCY'
        exporting
          date             = i_date
          foreign_currency = i_to
          local_amount     = l_value
          local_currency   = currency_local
        importing
          foreign_amount   = l_value
          foreign_factor   = l_foreign_factor
          local_factor     = l_local_factor
        exceptions
          no_rate_found    = 1
          overflow         = 2
          no_factors_found = 3
          no_spread_found  = 4
          derived_2_times  = 5
          others           = 6.
      if sy-subrc ne 0.
        zcx_generic=>raise( ).
      endif.

      l_value = l_value * l_foreign_factor / l_local_factor.

    endif.

    e_value = l_value.

  endmethod.


  method convert_iso2unit.

    select single msehi
      from t006
      into e_unit
      where isocode = i_iso.

  endmethod.


  method convert_unit2okei.

    select single mseh6
      from t006a
      into e_id
      where
        msehi eq i_id and
        spras eq sy-langu.

  endmethod.


  method get_category_text.

    if i_category_id is initial.
      return.
    endif.

    select single category_text
      from comm_categoryt
      into e_text
      where category_guid eq i_category_id and
            langu eq sy-langu.

  endmethod.


  method get_country_by_code.

    check i_code is not initial.

    select single land1
      from t005
      into e_country
      where intcn3 eq i_code.

  endmethod.


  method get_country_by_text.

    data l_text type string.
    l_text = zcl_text_static=>upper_case( i_text ).

    data lt_t005t type table of t005t.
    select *
      from t005t
      into table lt_t005t
      where
        spras eq langu_ru.

    field-symbols <ls_t005t> like line of lt_t005t.
    loop at lt_t005t assigning <ls_t005t>.

      <ls_t005t>-landx   = zcl_text_static=>upper_case( <ls_t005t>-landx ).
      <ls_t005t>-landx50 = zcl_text_static=>upper_case( <ls_t005t>-landx50 ).

      if <ls_t005t>-landx eq l_text or
         <ls_t005t>-landx50 eq l_text.
        e_id = <ls_t005t>-land1.
        return.
      endif.

    endloop.

  endmethod.


  method get_country_list.

    select t005~land1 t005t~landx
      from t005
        join t005t
          on t005t~land1 eq t005~land1
      into table et_values
      where
        t005t~spras eq sy-langu.

  endmethod.


  method get_country_text.

    if i_country is initial.
      return.
    endif.

    select single landx50
      from t005t
      into e_text
      where
        land1 eq i_country and
        spras eq sy-langu.

  endmethod.


  method get_currency_text.

    select single ltext
      from tcurt
      into e_text
      where spras eq sy-langu and
            waers eq i_currency.

  endmethod.


  method get_exchange_rate.

    data l_value type ze_value.
    l_value = 10000.

    l_value =
      convert_currency(
        i_value = l_value
        i_from  = i_from
        i_to    = i_to
        i_date  = i_date ).

    e_rate = l_value / 10000.

  endmethod.


  method get_product_text.

    if i_product_id is initial.
      return.
    endif.

    select single short_text
      from comm_product_idx
      into e_text
      where product_guid eq i_product_id and
            langu eq sy-langu.

  endmethod.


  method get_region_by_text.

    data l_text(100).
    l_text = zcl_text_static=>upper_case( i_text ).

    replace 'РЕСПУБЛИКА' in l_text with ` `.
    replace '-'          in l_text with ` `.
    replace 'Г.'         in l_text with ` `.
    replace 'ОБЛ.'       in l_text with ` `.
    replace 'КРАЙ'       in l_text with ` `.

    condense l_text.

    l_text = zcl_text_static=>get_word( l_text ).

    l_text = zcl_text_static=>like_name( l_text ).

    l_text = '%' && l_text && '%'.

    select single bland
      from t005u
      into e_id
      where
        land1 eq i_country and
        bezei like l_text.

  endmethod.


  method get_region_list.

    select bland as value bezei as text
      from t005u
      into table et_list
      where
        spras eq i_langu and
        land1 eq i_country.

  endmethod.


  method get_region_text.

    if i_region is initial.
      return.
    endif.

    data lt_list type zivalues.
    lt_list = get_region_list( i_country = i_country ).

    data ls_list like line of lt_list.
    read table lt_list into ls_list
      with key id = i_region.

    e_text = ls_list-text.

  endmethod.


  method get_region_values.

    check i_country is not initial.

    et_values = get_region_list( i_country ).

    if i_with_id eq abap_true.

      field-symbols <ls_value> like line of et_values.
      loop at et_values assigning <ls_value>.

        <ls_value>-text = <ls_value>-id && ` - ` && <ls_value>-text.

      endloop.

    endif.

    sort et_values by id.

  endmethod.


  method get_unit_id_by_text.

    select single msehi
      into e_id
      from t006a
      where
        spras eq sy-langu and
      ( mseht eq i_text or
        msehl eq i_text ).

  endmethod.


  method get_unit_text.

    if i_unit is initial.
      return.
    endif.

    select single msehl from t006a
      into e_text
      where spras eq i_langu and
            msehi eq i_unit.

  endmethod.


  method is_account_correct.

    data l_bic(20).
    l_bic = i_bic.

    data l_account(99).
    l_account = i_account.

    if strlen( l_account ) <> 20.
      return.
    endif.

    if strlen( l_bic ) <> 9.
      return.
    endif.

    data w type standard table of i.

    do 7 times.
      append 7 to w.
      append 1 to w.
      append 3 to w.
    enddo.
    append 7 to w.
    append 1 to w.

    if l_bic+6(3) eq '000' or
       l_bic+6(3) eq '001' or
       l_bic+6(3) eq '002'.
      concatenate '0' l_bic+4(2) l_account into l_account.
    else.
      concatenate l_bic+6(3) l_account into l_account.
    endif.

    data: prod type i.
    scalar(
      exporting
        i_v1 = l_account
        i_v2 = w
      changing
        c_res = prod ).

    data: rem type i.
    rem = prod mod 10.

    if rem <> 0.
      return.
    endif.

    e_is = abap_true.

  endmethod.


  method is_email_correct.

    data l_patern type string.
    l_patern = '^[a-zA-Zа-яА-Я0-9_\.\+\-]+@[a-zA-Zа-яА-Я0-9\-]+\.[a-zA-Zа-яА-Я0-9\-\.]+$'.

    data lr_matcher type ref to cl_abap_matcher.
    lr_matcher =
      cl_abap_matcher=>create(
        pattern     = l_patern
        text        = i_email
        ignore_case = abap_true ).

    e_is = lr_matcher->match( ).

  endmethod.


  method is_inn_correct.

    data: tinn12n2 type standard table of i.
    data: tinn12n1 type standard table of i.
    data: tinn10n1 type standard table of i.

    append 7 to tinn12n2.
    append 2 to tinn12n2.
    append 4 to tinn12n2.
    append 10 to tinn12n2.
    append 3 to tinn12n2.
    append 5 to tinn12n2.
    append 9 to tinn12n2.
    append 4 to tinn12n2.
    append 6 to tinn12n2.
    append 8 to tinn12n2.

    append 3 to tinn12n1.
    append 7 to tinn12n1.
    append 2 to tinn12n1.
    append 4 to tinn12n1.
    append 10 to tinn12n1.
    append 3 to tinn12n1.
    append 5 to tinn12n1.
    append 9 to tinn12n1.
    append 4 to tinn12n1.
    append 6 to tinn12n1.
    append 8 to tinn12n1.


    append 2 to tinn10n1.
    append 4 to tinn10n1.
    append 10 to tinn10n1.
    append 3 to tinn10n1.
    append 5 to tinn10n1.
    append 9 to tinn10n1.
    append 4 to tinn10n1.
    append 6 to tinn10n1.
    append 8 to tinn10n1.

    data l_inn(20).
    l_inn = i_inn.

    if strlen( l_inn ) <> 10 and strlen( l_inn ) <> 12.
      return.
    endif.

    data: prod type i.
    data: rem type i.

    if strlen( l_inn ) = 10.

      "1)
      scalar(
        exporting
          i_v1 = l_inn
          i_v2 = tinn10n1
        changing
          c_res = prod ).

      rem = prod mod 11.
      if rem = 10.
        rem = 0.
      endif.
      if rem <> l_inn+9(1).
        return.
      endif.

    elseif strlen( l_inn ) = 12.

      "1)
      scalar(
        exporting
          i_v1 = l_inn
          i_v2 = tinn12n1
        changing
          c_res = prod ).

      rem = prod mod 11.
      if rem = 10.
        rem = 0.
      endif.
      if rem <> l_inn+11(1).
        return.
      endif.

      "2)
      scalar(
        exporting
          i_v1 = l_inn
          i_v2 = tinn12n2
        changing
          c_res = prod ).

      rem = prod mod 11.
      if rem = 10.
        rem = 0.
      endif.
      if rem <> l_inn+10(1).
        return.
      endif.

    else.
      return.
    endif.

    e_is = abap_true.

  endmethod.


  method is_kpp_correct.

    data l_inn(20).
    l_inn = i_inn.

    data l_kpp(20).
    l_kpp = i_kpp.

    if strlen( l_kpp ) <> 9.
      return.
    endif.

    if l_kpp cn ' 1234567890'.
      return.
    endif.

    if strlen( l_inn ) < 2.
      return.
    endif.

***  if l_kpp+0(2) = '99' or l_kpp+0(2) = '98'.
***    "ok
***  elseif l_kpp+0(2) <> l_inn+0(2).
***    return.
***  endif.

    e_is = abap_true.

  endmethod.


  method is_ogrn_correct.

    constants: ogrn_len   type i value 13,
               ogrnip_len type i value 15,
               ogrn_ofs   type i value 12,
               ogrnip_ofs type i value 14.


    data: n_ogrn(ogrnip_len) type n.
    data: ofs type i value 14.
    data: val type i.
    data: len type i value 1.


    if i_ogrn is initial or not i_ogrn co ' 1234567890'.
      return.
    endif.

    syst-tfill = strlen( i_ogrn ).

* Separate ОГРН &amp; ОГРНИП
    case syst-tfill.
      when ogrn_len. " ОГРН

        n_ogrn = i_ogrn(ogrn_ofs).

        val = n_ogrn mod 11.

************************************************************
        if val > 9.
          clear val.
        endif.
************************************************************

        n_ogrn = i_ogrn.

      when ogrnip_len. " ОГРНИП

        n_ogrn = i_ogrn(ogrnip_ofs).

        val = n_ogrn mod 13.

        if val gt 9.
          val = val mod 10.
        endif.

        n_ogrn = i_ogrn.

      when others.
        return.
    endcase.

    if val ne n_ogrn+ofs(len).
      return.
    endif.

    e_is = abap_true.

  endmethod.


  method is_okpo_correct.

    check i_okpo is not initial.

    check i_okpo co ' 1234567890'.

    check
      strlen( i_okpo ) eq 8 or
      strlen( i_okpo ) eq 10.

    try.
        data n_okpo(10) type c.
        n_okpo = i_okpo.
      catch cx_root.
        return.
    endtry.

    if n_okpo is initial.
      return.
    endif.

    field-symbols: <wt> type i.

    data: gt_weight_okpo type standard table of i.
    append initial line to gt_weight_okpo assigning <wt>.
    <wt> = 1.
    append initial line to gt_weight_okpo assigning <wt>.
    <wt> = 2.
    append initial line to gt_weight_okpo assigning <wt>.
    <wt> = 3.
    append initial line to gt_weight_okpo assigning <wt>.
    <wt> = 4.
    append initial line to gt_weight_okpo assigning <wt>.
    <wt> = 5.
    append initial line to gt_weight_okpo assigning <wt>.
    <wt> = 6.
    append initial line to gt_weight_okpo assigning <wt>.
    <wt> = 7.
    append initial line to gt_weight_okpo assigning <wt>.
    <wt> = 8.
    append initial line to gt_weight_okpo assigning <wt>.
    <wt> = 9.
    append initial line to gt_weight_okpo assigning <wt>.
    <wt> = 10.
    append initial line to gt_weight_okpo assigning <wt>.
    <wt> = 1.

    data: start type i value 0.
    data: count type i value 7.
    data: ofs   type i.
    data: val   type i.
    data: sum   type i value is initial.
    data: tbx   type syst-tabix.
    data: ctr1  type i.
    data: ctr2  type i.
    data: len   type i value 1.

    count = strlen( i_okpo ) - 1.

*----------------------------------------------------------------------*
* .CODE
*----------------------------------------------------------------------*
    do count times.
      ofs = syst-index - 1.
      tbx = syst-index + start.
      val = n_okpo+ofs(len).
      read table gt_weight_okpo assigning <wt> index tbx.
      assert syst-subrc is initial.
      sum = sum + val * <wt>.
    enddo.

    ctr1 = sum mod 11.

    if ctr1 lt 10.

      val = ctr1.

    else.

      clear: sum.
      start = 2.
      do count times.
        ofs = syst-index - 1.
        tbx = syst-index + start.
        val = n_okpo+ofs(len).
        read table gt_weight_okpo assigning <wt> index tbx.
        assert syst-subrc is initial.
        sum = sum + val * <wt>.
      enddo.

      ctr2 = sum mod 11.

      if ctr2 = '10'.
        ctr2 = '0'.
      endif.

      val = ctr2.

    endif.

    check val eq n_okpo+count(len).

    e_is = abap_true.

  endmethod.


  method is_phone_correct.

    data l_phone type string.
    l_phone = i_phone.

    check strlen( l_phone ) eq 10.

    if l_phone cn '0123456789'.
      return.
    endif.

    r_correct = abap_true.

  endmethod.


  method scalar.

    c_res = 0.

    data l_v1(100).
    l_v1 = i_v1.

    data: d1 type n.
    data: d2 type i.
    data: index type i.

    do.

      index = sy-index.

      if strlen( l_v1 ) < 1.
        exit.
      endif.

      if lines( i_v2 ) < index.
        exit.
      endif.

      d1 = l_v1+0(1).

      read table i_v2 into d2 index index.

      c_res = c_res + d1 * d2.

      shift l_v1 left by 1 places.

    enddo.

  endmethod.
ENDCLASS.
