import 'dart:ui' show PlatformDispatcher;

import 'package:kalayanaexpresstracker/app/core/config.dart';

class CurrencyOption {
  const CurrencyOption({
    required this.code,
    required this.symbol,
    required this.name,
  });

  final String code;
  final String symbol;
  final String name;

  String get label => '$code  $symbol  $name';
}

class CurrencySymbolApi {
  const CurrencySymbolApi._();

  static const defaultOption = CurrencyOption(
    code: 'INR',
    symbol: '₹',
    name: 'Indian Rupee',
  );

  static const options = <CurrencyOption>[
    CurrencyOption(code: 'AED', symbol: 'د.إ', name: 'UAE Dirham'),
    CurrencyOption(code: 'AFN', symbol: '؋', name: 'Afghan Afghani'),
    CurrencyOption(code: 'ALL', symbol: 'L', name: 'Albanian Lek'),
    CurrencyOption(code: 'AMD', symbol: '֏', name: 'Armenian Dram'),
    CurrencyOption(
      code: 'ANG',
      symbol: 'ƒ',
      name: 'Netherlands Antillean Guilder',
    ),
    CurrencyOption(code: 'AOA', symbol: 'Kz', name: 'Angolan Kwanza'),
    CurrencyOption(code: 'ARS', symbol: r'$', name: 'Argentine Peso'),
    CurrencyOption(code: 'AUD', symbol: r'$', name: 'Australian Dollar'),
    CurrencyOption(code: 'AWG', symbol: 'ƒ', name: 'Aruban Florin'),
    CurrencyOption(code: 'AZN', symbol: '₼', name: 'Azerbaijani Manat'),
    CurrencyOption(code: 'BAM', symbol: 'KM', name: 'Bosnia-Herzegovina Mark'),
    CurrencyOption(code: 'BBD', symbol: r'$', name: 'Barbadian Dollar'),
    CurrencyOption(code: 'BDT', symbol: '৳', name: 'Bangladeshi Taka'),
    CurrencyOption(code: 'BGN', symbol: 'лв', name: 'Bulgarian Lev'),
    CurrencyOption(code: 'BHD', symbol: '.د.ب', name: 'Bahraini Dinar'),
    CurrencyOption(code: 'BIF', symbol: 'FBu', name: 'Burundian Franc'),
    CurrencyOption(code: 'BMD', symbol: r'$', name: 'Bermudian Dollar'),
    CurrencyOption(code: 'BND', symbol: r'$', name: 'Brunei Dollar'),
    CurrencyOption(code: 'BOB', symbol: 'Bs.', name: 'Bolivian Boliviano'),
    CurrencyOption(code: 'BRL', symbol: r'R$', name: 'Brazilian Real'),
    CurrencyOption(code: 'BSD', symbol: r'$', name: 'Bahamian Dollar'),
    CurrencyOption(code: 'BTN', symbol: 'Nu.', name: 'Bhutanese Ngultrum'),
    CurrencyOption(code: 'BWP', symbol: 'P', name: 'Botswana Pula'),
    CurrencyOption(code: 'BYN', symbol: 'Br', name: 'Belarusian Ruble'),
    CurrencyOption(code: 'BZD', symbol: r'BZ$', name: 'Belize Dollar'),
    CurrencyOption(code: 'CAD', symbol: r'$', name: 'Canadian Dollar'),
    CurrencyOption(code: 'CDF', symbol: 'FC', name: 'Congolese Franc'),
    CurrencyOption(code: 'CHF', symbol: 'CHF', name: 'Swiss Franc'),
    CurrencyOption(code: 'CLP', symbol: r'$', name: 'Chilean Peso'),
    CurrencyOption(code: 'CNY', symbol: '¥', name: 'Chinese Yuan'),
    CurrencyOption(code: 'COP', symbol: r'$', name: 'Colombian Peso'),
    CurrencyOption(code: 'CRC', symbol: '₡', name: 'Costa Rican Colon'),
    CurrencyOption(code: 'CUP', symbol: r'$', name: 'Cuban Peso'),
    CurrencyOption(code: 'CVE', symbol: r'$', name: 'Cape Verdean Escudo'),
    CurrencyOption(code: 'CZK', symbol: 'Kč', name: 'Czech Koruna'),
    CurrencyOption(code: 'DJF', symbol: 'Fdj', name: 'Djiboutian Franc'),
    CurrencyOption(code: 'DKK', symbol: 'kr', name: 'Danish Krone'),
    CurrencyOption(code: 'DOP', symbol: r'$', name: 'Dominican Peso'),
    CurrencyOption(code: 'DZD', symbol: 'د.ج', name: 'Algerian Dinar'),
    CurrencyOption(code: 'EGP', symbol: '£', name: 'Egyptian Pound'),
    CurrencyOption(code: 'ERN', symbol: 'Nfk', name: 'Eritrean Nakfa'),
    CurrencyOption(code: 'ETB', symbol: 'Br', name: 'Ethiopian Birr'),
    CurrencyOption(code: 'EUR', symbol: '€', name: 'Euro'),
    CurrencyOption(code: 'FJD', symbol: r'$', name: 'Fijian Dollar'),
    CurrencyOption(code: 'FKP', symbol: '£', name: 'Falkland Islands Pound'),
    CurrencyOption(code: 'GBP', symbol: '£', name: 'British Pound'),
    CurrencyOption(code: 'GEL', symbol: '₾', name: 'Georgian Lari'),
    CurrencyOption(code: 'GHS', symbol: '₵', name: 'Ghanaian Cedi'),
    CurrencyOption(code: 'GIP', symbol: '£', name: 'Gibraltar Pound'),
    CurrencyOption(code: 'GMD', symbol: 'D', name: 'Gambian Dalasi'),
    CurrencyOption(code: 'GNF', symbol: 'FG', name: 'Guinean Franc'),
    CurrencyOption(code: 'GTQ', symbol: 'Q', name: 'Guatemalan Quetzal'),
    CurrencyOption(code: 'GYD', symbol: r'$', name: 'Guyanese Dollar'),
    CurrencyOption(code: 'HKD', symbol: r'$', name: 'Hong Kong Dollar'),
    CurrencyOption(code: 'HNL', symbol: 'L', name: 'Honduran Lempira'),
    CurrencyOption(code: 'HTG', symbol: 'G', name: 'Haitian Gourde'),
    CurrencyOption(code: 'HUF', symbol: 'Ft', name: 'Hungarian Forint'),
    CurrencyOption(code: 'IDR', symbol: 'Rp', name: 'Indonesian Rupiah'),
    CurrencyOption(code: 'ILS', symbol: '₪', name: 'Israeli New Shekel'),
    CurrencyOption(code: 'INR', symbol: '₹', name: 'Indian Rupee'),
    CurrencyOption(code: 'IQD', symbol: 'ع.د', name: 'Iraqi Dinar'),
    CurrencyOption(code: 'IRR', symbol: '﷼', name: 'Iranian Rial'),
    CurrencyOption(code: 'ISK', symbol: 'kr', name: 'Icelandic Krona'),
    CurrencyOption(code: 'JMD', symbol: r'$', name: 'Jamaican Dollar'),
    CurrencyOption(code: 'JOD', symbol: 'د.ا', name: 'Jordanian Dinar'),
    CurrencyOption(code: 'JPY', symbol: '¥', name: 'Japanese Yen'),
    CurrencyOption(code: 'KES', symbol: 'KSh', name: 'Kenyan Shilling'),
    CurrencyOption(code: 'KGS', symbol: 'с', name: 'Kyrgyzstani Som'),
    CurrencyOption(code: 'KHR', symbol: '៛', name: 'Cambodian Riel'),
    CurrencyOption(code: 'KMF', symbol: 'CF', name: 'Comorian Franc'),
    CurrencyOption(code: 'KRW', symbol: '₩', name: 'South Korean Won'),
    CurrencyOption(code: 'KWD', symbol: 'د.ك', name: 'Kuwaiti Dinar'),
    CurrencyOption(code: 'KYD', symbol: r'$', name: 'Cayman Islands Dollar'),
    CurrencyOption(code: 'KZT', symbol: '₸', name: 'Kazakhstani Tenge'),
    CurrencyOption(code: 'LAK', symbol: '₭', name: 'Lao Kip'),
    CurrencyOption(code: 'LBP', symbol: 'ل.ل', name: 'Lebanese Pound'),
    CurrencyOption(code: 'LKR', symbol: 'Rs', name: 'Sri Lankan Rupee'),
    CurrencyOption(code: 'LRD', symbol: r'$', name: 'Liberian Dollar'),
    CurrencyOption(code: 'LSL', symbol: 'L', name: 'Lesotho Loti'),
    CurrencyOption(code: 'LYD', symbol: 'ل.د', name: 'Libyan Dinar'),
    CurrencyOption(code: 'MAD', symbol: 'د.م.', name: 'Moroccan Dirham'),
    CurrencyOption(code: 'MDL', symbol: 'L', name: 'Moldovan Leu'),
    CurrencyOption(code: 'MGA', symbol: 'Ar', name: 'Malagasy Ariary'),
    CurrencyOption(code: 'MKD', symbol: 'ден', name: 'Macedonian Denar'),
    CurrencyOption(code: 'MMK', symbol: 'K', name: 'Myanmar Kyat'),
    CurrencyOption(code: 'MNT', symbol: '₮', name: 'Mongolian Tugrik'),
    CurrencyOption(code: 'MOP', symbol: 'P', name: 'Macanese Pataca'),
    CurrencyOption(code: 'MRU', symbol: 'UM', name: 'Mauritanian Ouguiya'),
    CurrencyOption(code: 'MUR', symbol: '₨', name: 'Mauritian Rupee'),
    CurrencyOption(code: 'MVR', symbol: 'Rf', name: 'Maldivian Rufiyaa'),
    CurrencyOption(code: 'MWK', symbol: 'MK', name: 'Malawian Kwacha'),
    CurrencyOption(code: 'MXN', symbol: r'$', name: 'Mexican Peso'),
    CurrencyOption(code: 'MYR', symbol: 'RM', name: 'Malaysian Ringgit'),
    CurrencyOption(code: 'MZN', symbol: 'MT', name: 'Mozambican Metical'),
    CurrencyOption(code: 'NAD', symbol: r'$', name: 'Namibian Dollar'),
    CurrencyOption(code: 'NGN', symbol: '₦', name: 'Nigerian Naira'),
    CurrencyOption(code: 'NIO', symbol: r'C$', name: 'Nicaraguan Cordoba'),
    CurrencyOption(code: 'NOK', symbol: 'kr', name: 'Norwegian Krone'),
    CurrencyOption(code: 'NPR', symbol: '₨', name: 'Nepalese Rupee'),
    CurrencyOption(code: 'NZD', symbol: r'$', name: 'New Zealand Dollar'),
    CurrencyOption(code: 'OMR', symbol: 'ر.ع.', name: 'Omani Rial'),
    CurrencyOption(code: 'PAB', symbol: 'B/.', name: 'Panamanian Balboa'),
    CurrencyOption(code: 'PEN', symbol: 'S/', name: 'Peruvian Sol'),
    CurrencyOption(code: 'PGK', symbol: 'K', name: 'Papua New Guinean Kina'),
    CurrencyOption(code: 'PHP', symbol: '₱', name: 'Philippine Peso'),
    CurrencyOption(code: 'PKR', symbol: '₨', name: 'Pakistani Rupee'),
    CurrencyOption(code: 'PLN', symbol: 'zł', name: 'Polish Zloty'),
    CurrencyOption(code: 'PYG', symbol: '₲', name: 'Paraguayan Guarani'),
    CurrencyOption(code: 'QAR', symbol: 'ر.ق', name: 'Qatari Riyal'),
    CurrencyOption(code: 'RON', symbol: 'lei', name: 'Romanian Leu'),
    CurrencyOption(code: 'RSD', symbol: 'дин.', name: 'Serbian Dinar'),
    CurrencyOption(code: 'RUB', symbol: '₽', name: 'Russian Ruble'),
    CurrencyOption(code: 'RWF', symbol: 'RF', name: 'Rwandan Franc'),
    CurrencyOption(code: 'SAR', symbol: 'ر.س', name: 'Saudi Riyal'),
    CurrencyOption(code: 'SBD', symbol: r'$', name: 'Solomon Islands Dollar'),
    CurrencyOption(code: 'SCR', symbol: '₨', name: 'Seychellois Rupee'),
    CurrencyOption(code: 'SDG', symbol: 'ج.س.', name: 'Sudanese Pound'),
    CurrencyOption(code: 'SEK', symbol: 'kr', name: 'Swedish Krona'),
    CurrencyOption(code: 'SGD', symbol: r'$', name: 'Singapore Dollar'),
    CurrencyOption(code: 'SHP', symbol: '£', name: 'Saint Helena Pound'),
    CurrencyOption(code: 'SLE', symbol: 'Le', name: 'Sierra Leonean Leone'),
    CurrencyOption(code: 'SOS', symbol: 'Sh', name: 'Somali Shilling'),
    CurrencyOption(code: 'SRD', symbol: r'$', name: 'Surinamese Dollar'),
    CurrencyOption(code: 'SSP', symbol: '£', name: 'South Sudanese Pound'),
    CurrencyOption(
      code: 'STN',
      symbol: 'Db',
      name: 'Sao Tome and Principe Dobra',
    ),
    CurrencyOption(code: 'SYP', symbol: '£', name: 'Syrian Pound'),
    CurrencyOption(code: 'SZL', symbol: 'L', name: 'Eswatini Lilangeni'),
    CurrencyOption(code: 'THB', symbol: '฿', name: 'Thai Baht'),
    CurrencyOption(code: 'TJS', symbol: 'ЅМ', name: 'Tajikistani Somoni'),
    CurrencyOption(code: 'TMT', symbol: 'm', name: 'Turkmenistani Manat'),
    CurrencyOption(code: 'TND', symbol: 'د.ت', name: 'Tunisian Dinar'),
    CurrencyOption(code: 'TOP', symbol: r'T$', name: 'Tongan Paanga'),
    CurrencyOption(code: 'TRY', symbol: '₺', name: 'Turkish Lira'),
    CurrencyOption(
      code: 'TTD',
      symbol: r'$',
      name: 'Trinidad and Tobago Dollar',
    ),
    CurrencyOption(code: 'TWD', symbol: r'$', name: 'New Taiwan Dollar'),
    CurrencyOption(code: 'TZS', symbol: 'Sh', name: 'Tanzanian Shilling'),
    CurrencyOption(code: 'UAH', symbol: '₴', name: 'Ukrainian Hryvnia'),
    CurrencyOption(code: 'UGX', symbol: 'USh', name: 'Ugandan Shilling'),
    CurrencyOption(code: 'USD', symbol: r'$', name: 'US Dollar'),
    CurrencyOption(code: 'UYU', symbol: r'$', name: 'Uruguayan Peso'),
    CurrencyOption(code: 'UZS', symbol: 'soʻm', name: 'Uzbekistani Som'),
    CurrencyOption(code: 'VES', symbol: 'Bs.', name: 'Venezuelan Bolivar'),
    CurrencyOption(code: 'VND', symbol: '₫', name: 'Vietnamese Dong'),
    CurrencyOption(code: 'VUV', symbol: 'VT', name: 'Vanuatu Vatu'),
    CurrencyOption(code: 'WST', symbol: 'T', name: 'Samoan Tala'),
    CurrencyOption(
      code: 'XAF',
      symbol: 'FCFA',
      name: 'Central African CFA Franc',
    ),
    CurrencyOption(code: 'XCD', symbol: r'$', name: 'East Caribbean Dollar'),
    CurrencyOption(code: 'XOF', symbol: 'CFA', name: 'West African CFA Franc'),
    CurrencyOption(code: 'XPF', symbol: '₣', name: 'CFP Franc'),
    CurrencyOption(code: 'YER', symbol: '﷼', name: 'Yemeni Rial'),
    CurrencyOption(code: 'ZAR', symbol: 'R', name: 'South African Rand'),
    CurrencyOption(code: 'ZMW', symbol: 'ZK', name: 'Zambian Kwacha'),
    CurrencyOption(code: 'ZWL', symbol: r'$', name: 'Zimbabwean Dollar'),
  ];

  // ISO 3166-1 alpha-2 country code -> ISO 4217 currency code.
  static const _currencyByCountry = <String, String>{
    'AE': 'AED', 'AF': 'AFN', 'AL': 'ALL', 'AM': 'AMD',
    'CW': 'ANG', 'SX': 'ANG', 'AO': 'AOA', 'AR': 'ARS',
    'AU': 'AUD', 'AW': 'AWG', 'AZ': 'AZN', 'BA': 'BAM',
    'BB': 'BBD', 'BD': 'BDT', 'BG': 'BGN', 'BH': 'BHD',
    'BI': 'BIF', 'BM': 'BMD', 'BN': 'BND', 'BO': 'BOB',
    'BR': 'BRL', 'BS': 'BSD', 'BT': 'BTN', 'BW': 'BWP',
    'BY': 'BYN', 'BZ': 'BZD', 'CA': 'CAD', 'CD': 'CDF',
    'CH': 'CHF', 'LI': 'CHF', 'CL': 'CLP', 'CN': 'CNY',
    'CO': 'COP', 'CR': 'CRC', 'CU': 'CUP', 'CV': 'CVE',
    'CZ': 'CZK', 'DJ': 'DJF', 'DK': 'DKK', 'GL': 'DKK',
    'FO': 'DKK', 'DO': 'DOP', 'DZ': 'DZD', 'EG': 'EGP',
    'ER': 'ERN', 'ET': 'ETB', 'FJ': 'FJD', 'FK': 'FKP',
    'GB': 'GBP', 'GG': 'GBP', 'JE': 'GBP', 'IM': 'GBP',
    'GE': 'GEL', 'GH': 'GHS', 'GI': 'GIP', 'GM': 'GMD',
    'GN': 'GNF', 'GT': 'GTQ', 'GY': 'GYD', 'HK': 'HKD',
    'HN': 'HNL', 'HT': 'HTG', 'HU': 'HUF', 'ID': 'IDR',
    'IL': 'ILS', 'IN': 'INR', 'IQ': 'IQD', 'IR': 'IRR',
    'IS': 'ISK', 'JM': 'JMD', 'JO': 'JOD', 'JP': 'JPY',
    'KE': 'KES', 'KG': 'KGS', 'KH': 'KHR', 'KM': 'KMF',
    'KR': 'KRW', 'KW': 'KWD', 'KY': 'KYD', 'KZ': 'KZT',
    'LA': 'LAK', 'LB': 'LBP', 'LK': 'LKR', 'LR': 'LRD',
    'LS': 'LSL', 'LY': 'LYD', 'MA': 'MAD', 'MD': 'MDL',
    'MG': 'MGA', 'MK': 'MKD', 'MM': 'MMK', 'MN': 'MNT',
    'MO': 'MOP', 'MR': 'MRU', 'MU': 'MUR', 'MV': 'MVR',
    'MW': 'MWK', 'MX': 'MXN', 'MY': 'MYR', 'MZ': 'MZN',
    'NA': 'NAD', 'NG': 'NGN', 'NI': 'NIO', 'NO': 'NOK',
    'NP': 'NPR', 'NZ': 'NZD', 'OM': 'OMR', 'PA': 'PAB',
    'PE': 'PEN', 'PG': 'PGK', 'PH': 'PHP', 'PK': 'PKR',
    'PL': 'PLN', 'PY': 'PYG', 'QA': 'QAR', 'RO': 'RON',
    'RS': 'RSD', 'RU': 'RUB', 'RW': 'RWF', 'SA': 'SAR',
    'SB': 'SBD', 'SC': 'SCR', 'SD': 'SDG', 'SE': 'SEK',
    'SG': 'SGD', 'SH': 'SHP', 'SL': 'SLE', 'SO': 'SOS',
    'SR': 'SRD', 'SS': 'SSP', 'ST': 'STN', 'SY': 'SYP',
    'SZ': 'SZL', 'TH': 'THB', 'TJ': 'TJS', 'TM': 'TMT',
    'TN': 'TND', 'TO': 'TOP', 'TR': 'TRY', 'TT': 'TTD',
    'TW': 'TWD', 'TZ': 'TZS', 'UA': 'UAH', 'UG': 'UGX',
    'US': 'USD', 'UY': 'UYU', 'UZ': 'UZS', 'VE': 'VES',
    'VN': 'VND', 'VU': 'VUV', 'WS': 'WST', 'YE': 'YER',
    'ZA': 'ZAR', 'ZM': 'ZMW', 'ZW': 'ZWL',
    // Eurozone.
    'AT': 'EUR', 'AD': 'EUR', 'BE': 'EUR', 'CY': 'EUR',
    'EE': 'EUR', 'FI': 'EUR', 'FR': 'EUR', 'DE': 'EUR',
    'GR': 'EUR', 'IE': 'EUR', 'IT': 'EUR', 'LV': 'EUR',
    'LT': 'EUR', 'LU': 'EUR', 'MT': 'EUR', 'MC': 'EUR',
    'ME': 'EUR', 'NL': 'EUR', 'PT': 'EUR', 'SM': 'EUR',
    'SK': 'EUR', 'SI': 'EUR', 'ES': 'EUR', 'VA': 'EUR',
    'XK': 'EUR',
    // CFA franc zones.
    'CM': 'XAF', 'CF': 'XAF', 'TD': 'XAF', 'CG': 'XAF',
    'GQ': 'XAF', 'GA': 'XAF',
    'BJ': 'XOF', 'BF': 'XOF', 'CI': 'XOF', 'GW': 'XOF',
    'ML': 'XOF', 'NE': 'XOF', 'SN': 'XOF', 'TG': 'XOF',
    // Eastern Caribbean dollar zone.
    'AG': 'XCD', 'DM': 'XCD', 'GD': 'XCD', 'KN': 'XCD',
    'LC': 'XCD', 'VC': 'XCD',
    // CFP franc zone.
    'PF': 'XPF', 'NC': 'XPF', 'WF': 'XPF',
  };

  static CurrencyOption fromCode(String? code) {
    final normalized = code?.trim().toUpperCase();
    if (normalized == null || normalized.isEmpty) return defaultOption;
    return options.firstWhere(
      (option) => option.code == normalized,
      orElse: () => defaultOption,
    );
  }

  /// Guesses the user's currency from the device's region setting
  /// (e.g. the "Region" in iOS Settings or Android system locale).
  /// Falls back to [defaultOption] when the region is unset or unmapped.
  static CurrencyOption fromDeviceRegion() {
    final countryCode = PlatformDispatcher.instance.locale.countryCode
        ?.toUpperCase();
    final currencyCode = countryCode == null
        ? null
        : _currencyByCountry[countryCode];
    return fromCode(currencyCode);
  }

  static CurrencyOption fromProfile(Map<String, dynamic> profile) {
    final code = profile['currencyCode']?.toString();
    final savedSymbol = profile['currencySymbol']?.toString().trim();
    final option = fromCode(code);
    if (savedSymbol == null || savedSymbol.isEmpty) return option;
    return CurrencyOption(
      code: option.code,
      symbol: savedSymbol,
      name: option.name,
    );
  }

  static List<CurrencyOption> search(String query) {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) return options;
    return options
        .where(
          (option) =>
              option.code.toLowerCase().contains(normalized) ||
              option.symbol.toLowerCase().contains(normalized) ||
              option.name.toLowerCase().contains(normalized),
        )
        .toList(growable: false);
  }

  static void applyToAppConfig(CurrencyOption option) {
    AppConfig.setCurrency(code: option.code, symbol: option.symbol);
  }
}
