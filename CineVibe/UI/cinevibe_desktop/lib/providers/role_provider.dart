import 'package:cinevibe_desktop/model/role_response.dart';
import 'package:cinevibe_desktop/providers/base_provider.dart';

class RoleProvider extends BaseProvider<RoleResponse> {
  RoleProvider() : super("Role");

  @override
  RoleResponse fromJson(dynamic json) {
    return RoleResponse.fromJson(json);
  }
}
