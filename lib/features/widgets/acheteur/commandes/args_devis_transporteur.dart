/// Trio nécessaire pour interroger `logisticsService.getQuotes(...)`
/// depuis la page « Choisir mon transporteur » côté acheteur.
class ArgsDevisTransporteur {
  const ArgsDevisTransporteur({
    required this.origineZone,
    required this.destinationZone,
    required this.quantiteKg,
  });

  /// Zone d'origine du transport (ex: « Daloa »).
  final String origineZone;

  /// Zone de destination du transport (ex: « Abidjan »).
  final String destinationZone;

  /// Quantité à transporter en kilos.
  final double quantiteKg;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ArgsDevisTransporteur &&
          other.origineZone == origineZone &&
          other.destinationZone == destinationZone &&
          other.quantiteKg == quantiteKg;

  @override
  int get hashCode => Object.hash(origineZone, destinationZone, quantiteKg);
}
