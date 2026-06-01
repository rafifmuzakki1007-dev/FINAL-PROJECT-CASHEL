import '../models/income_model.dart';

class ChartServices {
  static List<IncomeModel> getMockIncome() {
    return [
      IncomeModel(month: 'JAN', value: 10),
      IncomeModel(month: 'FEB', value: 45),
      IncomeModel(month: 'MAR', value: 65),
      IncomeModel(month: 'APR', value: 40),
      IncomeModel(month: 'MAY', value: 55),
      IncomeModel(month: 'JUN', value: 80),
    ];
  }
}