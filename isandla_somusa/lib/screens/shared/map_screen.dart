import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../models/donation_model.dart';
import '../../providers/donation_provider.dart';
import '../../utils/app_theme.dart';
import '../../utils/app_constants.dart';
import 'package:provider/provider.dart';
import '../donor/donation_detail_screen.dart';

class MapScreen extends StatefulWidget {
  final double lat, lng;
  const MapScreen({super.key, required this.lat, required this.lng});
  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapCtrl;
  final Set<Marker> _markers = {};

  @override
  Widget build(BuildContext context) {
    final prov = context.read<DonationProvider>();
    return StreamBuilder<List<DonationModel>>(
      stream: prov.streamAvailable(),
      builder: (ctx, snap) {
        if (snap.hasData) {
          _markers.clear();
          for (final d in snap.data!) {
            _markers.add(Marker(
              markerId: MarkerId(d.id),
              position: LatLng(d.latitude, d.longitude),
              infoWindow: InfoWindow(
                title: d.title,
                snippet: '${d.quantity} ${d.unit} · ${d.donorName}',
                onTap: () => Navigator.push(ctx, MaterialPageRoute(
                  builder: (_) => DonationDetailScreen(donation: d, isRecipientView: true))),
              ),
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
            ));
          }
        }
        return Stack(children: [
          GoogleMap(
            onMapCreated: (c) => _mapCtrl = c,
            initialCameraPosition: CameraPosition(
              target: LatLng(widget.lat, widget.lng),
              zoom: AppConstants.defaultZoom,
            ),
            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
          ),
          if (snap.hasData)
            Positioned(
              top: 16, left: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: AppTheme.tealGreen, borderRadius: BorderRadius.circular(20)),
                child: Text('${snap.data!.length} donations nearby',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
              ),
            ),
        ]);
      },
    );
  }
}
