abstract class AuthServiceInterface {
  Future<void> login(String username, String password);
  void logout();
}
