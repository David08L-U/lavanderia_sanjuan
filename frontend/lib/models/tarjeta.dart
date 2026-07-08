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

  TarjetaGuardada copyWith({bool? principal}) => TarjetaGuardada(
    marca: marca,
    ultimosDigitos: ultimosDigitos,
    expira: expira,
    principal: principal ?? this.principal,
  );
}
