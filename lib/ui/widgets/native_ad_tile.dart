part of '../app_ui.dart';

class _NativeAdTile extends StatefulWidget {
  final String adUnitId;

  const _NativeAdTile({required this.adUnitId});

  @override
  State<_NativeAdTile> createState() => _NativeAdTileState();
}

class _NativeAdTileState extends State<_NativeAdTile> {
  NativeAd? _ad;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    if (widget.adUnitId.isEmpty) return;
    _ad = NativeAd(
      adUnitId: widget.adUnitId,
      factoryId: 'listTile',
      request: const AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (_) {
          if (!mounted) return;
          setState(() => _isLoaded = true);
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          if (!mounted) return;
          setState(() => _isLoaded = false);
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded || _ad == null) {
      return const SizedBox.shrink();
    }
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      height: 72,
      child: AdWidget(ad: _ad!),
    );
  }
}
