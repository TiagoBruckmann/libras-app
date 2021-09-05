class Users {

  int id;
  String mail;
  String password;

  Users({ this.id, this.mail, this.password });

  factory Users.fromJson(Map<String, dynamic> json) {
    return Users(
      id: json['id'],
      mail: json['mail'],
      password: json['password'],
    );
  }

  @override
  String toString() => mail;
}