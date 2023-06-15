import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  return runApp(const YoutubeApp());
}

class YoutubeApp extends StatelessWidget {
  const YoutubeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'YouTube',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.red,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // final String channelId = 'YOUR_YOUTUBE_CHANNEL_ID';
  List<dynamic> videoList = [];

  @override
  void initState() {
    super.initState();
    fetchVideos();
  }

  void fetchVideos() async {
    final apiKey = dotenv.env['apiKey'] ?? "";
    var response = await http.get(Uri.parse(
        'https://www.googleapis.com/youtube/v3/search?part=snippet&maxResults=10&order=date&type=video&key=$apiKey'));
    // 'https://www.googleapis.com/youtube/v3/search?part=snippet&channelId=$channelId&maxResults=10&order=date&type=video&key=$apiKey'));

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      setState(() {
        videoList = data['items'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('YouTube'),
        backgroundColor: Colors.redAccent.shade700,
      ),
      body: ListView.builder(
        itemCount: videoList.length,
        itemBuilder: (context, index) {
          var video = videoList[index]['snippet'];
          var videoId = videoList[index]['id']['videoId'];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VideoPlayerPage(videoId: videoId),
                ),
              );
            },
            child: Card(
              child: Column(
                children: [
                  Image.network(video['thumbnails']['high']['url']),
                  ListTile(
                    leading: CircleAvatar(
                      backgroundImage:
                          NetworkImage(video['thumbnails']['high']['url']),
                    ),
                    title: Text(video['title']),
                    subtitle: Text(video['channelTitle']),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class VideoPlayerPage extends StatelessWidget {
  final String videoId;

  VideoPlayerPage({required this.videoId});

  @override
  Widget build(BuildContext context) {
    YoutubePlayerController _controller = YoutubePlayerController(
      initialVideoId: videoId,
      flags: YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
      ),
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.redAccent.shade700,
      ),
      body: YoutubePlayer(
        controller: _controller,
        showVideoProgressIndicator: true,
      ),
    );
  }
}
