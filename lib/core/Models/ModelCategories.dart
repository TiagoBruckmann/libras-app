class ModelCategories {

  int id;
  String name;

  ModelCategories( this.id, this.name );

  ModelCategories.complete( int id, String name ) {
    this.id = id;
    this.name = name;
  }

  factory ModelCategories.fromJson( Map<String, dynamic> json ) {
    return ModelCategories (
      json["id"],
      json["name"]
    );
  }

  @override
  String toString() => name;
}