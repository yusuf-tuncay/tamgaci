import 'package:floor/floor.dart';

@DatabaseView('''
  SELECT 
    customer_type AS customerType,
    COUNT(*) AS count
  FROM customers 
  WHERE is_active = 1 
  GROUP BY customer_type
''')
class CustomerTypeStat {
  final String customerType;
  final int count;

  CustomerTypeStat(this.customerType, this.count);
}

@DatabaseView('''
  SELECT 
    city,
    COUNT(*) AS count
  FROM customers
  WHERE is_active = 1 AND city IS NOT NULL
  GROUP BY city
  ORDER BY count DESC
  LIMIT 10
''')
class CityCustomerCount {
  final String city;
  final int count;

  CityCustomerCount(this.city, this.count);
}

@DatabaseView('''
  SELECT 
    strftime('%Y-%m', datetime(created_at / 1000, 'unixepoch')) AS month,
    COUNT(*) AS count
  FROM customers
  GROUP BY month
  ORDER BY month DESC
  LIMIT 12
''')
class MonthlyCustomerStat {
  final String month;
  final int count;

  MonthlyCustomerStat(this.month, this.count);
}
