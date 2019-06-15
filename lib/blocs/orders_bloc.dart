import 'dart:async';

import 'package:komodo_dex/model/order.dart';
import 'package:komodo_dex/model/orders.dart';
import 'package:komodo_dex/services/market_maker_service.dart';
import 'package:komodo_dex/widgets/bloc_provider.dart';

final ordersBloc = OrdersBloc();

class OrdersBloc implements BlocBase {
  List<Order> orders;

  StreamController<List<Order>> _ordersController =
      StreamController<List<Order>>.broadcast();
  Sink<List<Order>> get _inOrders => _ordersController.sink;
  Stream<List<Order>> get outOrders => _ordersController.stream;

  Orders currentOrders;

  StreamController<Orders> _currentOrdersController =
      StreamController<Orders>.broadcast();
  Sink<Orders> get _inCurrentOrders => _currentOrdersController.sink;
  Stream<Orders> get outCurrentOrders => _currentOrdersController.stream;

  @override
  void dispose() {
    _currentOrdersController.close();
    _ordersController.close();
  }

  void updateOrders() async {
    Orders newOrders = await mm2.getMyOrders();
    List<Order> orders = new List<Order>();

    for (var entry in newOrders.result.takerOrders.entries) {
      orders.add(Order(
          base: entry.value.request.base,
          rel: entry.value.request.rel,
          orderType: OrderType.TAKER,
          createdAt: entry.value.createdAt,
          baseAmount: entry.value.request.baseAmount,
          relAmount: entry.value.request.relAmount,
          uuid: entry.key));
    }
    for (var entry in newOrders.result.makerOrders.entries) {
      orders.add(Order(
          baseAmount: entry.value.maxBaseVol,
          base: entry.value.base,
          rel: entry.value.rel,
          orderType: OrderType.MAKER,
          createdAt: entry.value.createdAt,
          relAmount: (double.parse(entry.value.price) * double.parse(entry.value.maxBaseVol)).toString(),
          uuid: entry.key));
    }
    this.orders = orders;
    _inOrders.add(this.orders);

    this.currentOrders = newOrders;
    _inCurrentOrders.add(this.currentOrders);
  }

  Future<void> cancelOrder(String uuid) async{
    await mm2.cancelOrder(uuid);
    updateOrders();
  }
}
