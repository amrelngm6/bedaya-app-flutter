class Invoice {
  final int invoiceId;
  String? code;
  String? description;
  String? status;
  String? date;
  String? dueDate;
  String? paymentMethod;
  double? subtotal;
  double? discountAmount;
  double? taxAmount;
  double? totalAmount;
  List<InvoiceItem>? items;

  Invoice({
    required this.invoiceId,
    this.code,
    this.description,
    this.status,
    this.date,
    this.paymentMethod,
    this.subtotal,
    this.totalAmount,
    this.discountAmount,
    this.taxAmount,
    this.items,
  });

  factory Invoice.model() {
    return Invoice(invoiceId: 0, code: '');
  }

  factory Invoice.fromJson(body) {
    List<InvoiceItem>? itemsList = [];
    itemsList = (body['services'] as List<dynamic>?)
        ?.map((item) => InvoiceItem.fromJson(item))
        .toList();

    return Invoice(
      invoiceId: body['invoice_id'] as int,
      code: body['code'],
      description: body['description'] as String?,
      status: body['status'],
      date: body['date'],
      subtotal: double.parse(body['subtotal'].toString()),
      discountAmount: double.parse(body['discount_amount'].toString()),
      totalAmount: double.parse(body['total_amount'].toString()),
      taxAmount: double.parse(body['tax_amount'].toString()),
      items: itemsList,
      paymentMethod: body['payment_method'] as String?,
    );
  }

  static List<Invoice>? listFromJson(dynamic data) {
    if (data == null) {
      return null;
    }

    Iterable itemsList = data;
    List<Invoice>? list = data != null
        ? List<Invoice>.from(itemsList.map((model) => Invoice.fromJson(model)))
        : [];

    return list;
  }
}

class InvoiceItem {
  final String serviceName;
  final int quantity;
  final double unitPrice;
  final double subtotal;
  final double total;

  InvoiceItem({
    required this.serviceName,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
    required this.total,
  });

  factory InvoiceItem.fromJson(Map<String, dynamic> json) {
    return InvoiceItem(
      serviceName: json['service_name'] as String,
      quantity: json['quantity'] as int,
      unitPrice: double.parse(json['unit_price'].toString()),
      subtotal: double.parse(json['subtotal'].toString()),
      total: double.parse(json['total'].toString()),
    );
  }
}
