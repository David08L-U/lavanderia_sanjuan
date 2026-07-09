enum MarcaTarjeta { mastercard, visa }

class TarjetaGuardada {
  const TarjetaGuardada({
    required this.marca,
    required this.ultimosDigitos,
    required this.expira,
    this.principal = false,
  });

  final MarcaTarjeta marca;
  final String ultimosDigitos;
  final String expira;
  final bool principal;

  factory TarjetaGuardada.fromJson(Map<String, dynamic> json) => TarjetaGuardada(
    marca: json['marca']?.toString() == 'mastercard' ? MarcaTarjeta.mastercard : MarcaTarjeta.visa,
    ultimosDigitos: json['ultimosDigitos']?.toString() ?? '',
    expira: json['expira']?.toString() ?? '',
    principal: json['principal'] == true,
  );

  Map<String, dynamic> toJson() => {
    'marca': marca.name,
    'ultimosDigitos': ultimosDigitos,
    'expira': expira,
    'principal': principal,
  };

  TarjetaGuardada copyWith({bool? principal}) => TarjetaGuardada(
    marca: marca,
    ultimosDigitos: ultimosDigitos,
    expira: expira,
    principal: principal ?? this.principal,
  );
}
