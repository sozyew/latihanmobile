class VenueGate {
  final String id;
  final String name;
  final String location;
  final double latitude;
  final double longitude;

  final double mapX;
  final double mapY;

  const VenueGate({
    required this.id,
    required this.name,
    required this.location,
    required this.latitude,
    required this.longitude,
    required this.mapX,
    required this.mapY,
  });
  // DATA STATIS: koordinat GPS dan posisi marker tiap gate
  static const List<VenueGate> all = [
    VenueGate(
      id: 'gate1',
      name: 'Gate 1 - Republic Blvd',
      location: 'Republic Boulevard',
      latitude: 1.2908,
      longitude: 103.8638,
      mapX: 0.91,
      mapY: 0.22,
    ),
    VenueGate(
      id: 'gate2',
      name: 'Gate 2 - Temasek Ave',
      location: 'Temasek Avenue',
      latitude: 1.2920,
      longitude: 103.8595,
      mapX: 0.65,
      mapY: 0.51,
    ),
    VenueGate(
      id: 'gate3a',
      name: 'Gate 3A - Stamford',
      location: 'Stamford Road',
      latitude: 1.2945,
      longitude: 103.8535,
      mapX: 0.33,
      mapY: 0.19,
    ),
    VenueGate(
      id: 'gate3b',
      name: 'Gate 3B - Stamford',
      location: 'Stamford Road',
      latitude: 1.2950,
      longitude: 103.8540,
      mapX: 0.35,
      mapY: 0.15,
    ),
    VenueGate(
      id: 'gate4',
      name: 'Gate 4 - Empress',
      location: 'Empress Place',
      latitude: 1.2885,
      longitude: 103.8505,
      mapX: 0.04,
      mapY: 0.45,
    ),
    VenueGate(
      id: 'gate5',
      name: 'Gate 5 - Fullerton',
      location: 'Fullerton Road',
      latitude: 1.2855,
      longitude: 103.8515,
      mapX: 0.08,
      mapY: 0.72,
    ),
    VenueGate(
      id: 'gate6',
      name: 'Gate 6 - Jubilee',
      location: 'Jubilee Bridge',
      latitude: 1.2868,
      longitude: 103.8560,
      mapX: 0.19,
      mapY: 0.69,
    ),
    VenueGate(
      id: 'gate7',
      name: 'Gate 7 - Marina Square',
      location: 'Marina Square',
      latitude: 1.2910,
      longitude: 103.8570,
      mapX: 0.39,
      mapY: 0.38,
    ),
    VenueGate(
      id: 'gate8',
      name: 'Gate 8 - Helix',
      location: 'Helix Bridge',
      latitude: 1.2870,
      longitude: 103.8600,
      mapX: 0.48,
      mapY: 0.82,
    ),
  ];
}
