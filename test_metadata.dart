/// Simple test script to check metadata parsing
import 'lib/data/local_audio_service.dart';

void main() async {
  // Test MP3 file
  final mp3Path = 'C:\\Users\\pomyu\\Documents\\appmaker\\apple music\\flutter_application_4\\蝶々結び.mp3';
  final m4aPath = 'C:\\Users\\pomyu\\Downloads\\三原色.m4a';
  
  final service = LocalAudioServiceImpl();
  
  print('=' * 80);
  print('Testing MP3: $mp3Path');
  print('=' * 80);
  
  try {
    final mp3Meta = await service.getMetadata(mp3Path);
    print('✓ MP3 Metadata:');
    print('  Title: ${mp3Meta.title}');
    print('  Artist: ${mp3Meta.artist}');
    print('  Album: ${mp3Meta.album}');
    print('  Duration: ${mp3Meta.duration}');
    print('  Artwork: ${mp3Meta.artworkData != null ? mp3Meta.artworkData!.length : 'None'} bytes');
  } catch (e) {
    print('✗ Error: $e');
  }
  
  print('');
  print('=' * 80);
  print('Testing M4A: $m4aPath');
  print('=' * 80);
  
  try {
    final m4aMeta = await service.getMetadata(m4aPath);
    print('✓ M4A Metadata:');
    print('  Title: ${m4aMeta.title}');
    print('  Artist: ${m4aMeta.artist}');
    print('  Album: ${m4aMeta.album}');
    print('  Duration: ${m4aMeta.duration}');
    print('  Artwork: ${m4aMeta.artworkData != null ? m4aMeta.artworkData!.length : 'None'} bytes');
  } catch (e) {
    print('✗ Error: $e');
  }
}
