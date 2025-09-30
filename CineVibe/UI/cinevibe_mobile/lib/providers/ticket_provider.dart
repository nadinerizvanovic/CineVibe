import 'package:cinevibe_mobile/model/ticket.dart';
import 'package:cinevibe_mobile/providers/base_provider.dart';

class TicketProvider extends BaseProvider<Ticket> {
  TicketProvider() : super("Ticket");

  @override
  Ticket fromJson(dynamic json) {
    return Ticket.fromJson(json);
  }
}
