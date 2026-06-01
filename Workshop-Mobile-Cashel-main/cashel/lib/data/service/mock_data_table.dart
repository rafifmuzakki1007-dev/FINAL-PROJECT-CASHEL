import '../models/user_order_model.dart';

class TableServices {
  static List<UserOrderModel> getLatestHistory() {
    return [
      UserOrderModel(number: '#654321', userName: 'Freya Nilsen', date: '20 Mar', status: 'Success', totalPrice: 50000),
      UserOrderModel(number: '#345678', userName: 'Liv Hansen', date: '21 Mar', status: 'Pending', totalPrice: 25000),
      UserOrderModel(number: '#901234', userName: 'Ingrid Halvorsen', date: '17 Mar', status: 'Success', totalPrice: 120000),
      UserOrderModel(number: '#789012', userName: 'Kasper Madsen', date: '19 Mar', status: 'Failed', totalPrice: 15000),
      UserOrderModel(number: '#123456', userName: 'Soren Jorge', date: '18 Mar', status: 'Success', totalPrice: 45000),
    ];
  }
}