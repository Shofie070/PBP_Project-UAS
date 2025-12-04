import 'package:equatable/equatable.dart';

enum PaymentStatus { initial, loading, success, failure }

class PaymentState extends Equatable {
  final PaymentStatus status;
  final String selectedPaymentMethod;
  final String email;
  final Map<String, dynamic>? receiptData;
  final String? errorMessage;

  const PaymentState({
    this.status = PaymentStatus.initial,
    this.selectedPaymentMethod = 'credit_card',
    this.email = '',
    this.receiptData,
    this.errorMessage,
  });

  PaymentState copyWith({
    PaymentStatus? status,
    String? selectedPaymentMethod,
    String? email,
    Map<String, dynamic>? receiptData,
    String? errorMessage,
  }) {
    return PaymentState(
      status: status ?? this.status,
      selectedPaymentMethod:
          selectedPaymentMethod ?? this.selectedPaymentMethod,
      email: email ?? this.email,
      receiptData: receiptData ?? this.receiptData,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        selectedPaymentMethod,
        email,
        receiptData,
        errorMessage,
      ];
}
