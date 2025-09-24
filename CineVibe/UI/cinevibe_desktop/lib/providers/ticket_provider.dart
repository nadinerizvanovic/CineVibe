import 'package:cinevibe_desktop/model/ticket.dart';
import 'package:cinevibe_desktop/providers/base_provider.dart';

class TicketProvider extends BaseProvider<Ticket> {
  TicketProvider() : super("Ticket");

  @override
  Ticket fromJson(dynamic json) {
    return Ticket.fromJson(json);
  }
}
