class UserOrderModel {
  final String number;
  final String userName;
  final String date;
  final String status; // Contoh: 'Success', 'Pending', 'Failed'
  final int totalPrice;

  UserOrderModel({
    required this.number,
    required this.userName,
    required this.date,
    required this.status,
    required this.totalPrice,
  });
}