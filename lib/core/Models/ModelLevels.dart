class ModelLevels {

  int id;
  String name;

  ModelLevels( this.id, this.name );

  ModelLevels.complete( int id, String name ) {
    this.id = id;
    this.name = name;
  }

  factory ModelLevels.fromJson( Map<String, dynamic> json ) {
    return ModelLevels (
        json["id"],
        json["name"],
    );
  }

  @override
  String toString() => name;
}