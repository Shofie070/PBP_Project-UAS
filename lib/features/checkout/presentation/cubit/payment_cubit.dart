import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../model/model.dart';
import 'payment_state.dart';

class PaymentCubit extends Cubit<PaymentState> {
  PaymentCubit() : super(const PaymentState());

  Future<void> loadInitialData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString('current_user_email') ??
          prefs.getString('user_email') ??
          '';
      emit(state.copyWith(email: email));
    } catch (e) {
      // ignore
    }
  }

  void updateEmail(String email) {
    emit(state.copyWith(email: email));
  }

  void selectPaymentMethod(String method) {
    emit(state.copyWith(selectedPaymentMethod: method));
  }

  Future<void> processPayment(
      List<Product> products, double totalAmount) async {
    if (state.selectedPaymentMethod.isEmpty) {
      emit(state.copyWith(
          status: PaymentStatus.failure,
          errorMessage: 'Pilih metode pembayaran terlebih dahulu'));
      return;
    }
    emit(state.copyWith(status: PaymentStatus.loading));
    try {
      // Simulate processing
      await Future.delayed(const Duration(seconds: 2));

      final receiptData = {
        'id': 'RCPT-${DateTime.now().millisecondsSinceEpoch}',
        'timestamp': DateTime.now().toIso8601String(),
        'email': state.email,
        'items': products.map((p) => p.toJson()).toList(),
        'subtotal': totalAmount,
        'shipping': 10000.0,
        'tax': totalAmount * 0.1,
        'total': totalAmount + 10000.0 + (totalAmount * 0.1),
        'paymentMethod': state.selectedPaymentMethod,
      };

      final prefs = await SharedPreferences.getInstance();
      final history = prefs.getStringList('purchase_history') ?? [];
      history.add(jsonEncode(receiptData));
      await prefs.setStringList('purchase_history', history);

      emit(state.copyWith(
          status: PaymentStatus.success, receiptData: receiptData));
    } catch (e) {
      emit(state.copyWith(
          status: PaymentStatus.failure, errorMessage: e.toString()));
    }
  }
}
