import 'package:flutter/material.dart';
import 'package:grpc/grpc.dart';
import 'src/generated/chat.pb.dart';
import 'src/generated/chat.pbgrpc.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'gRPC Chat Client',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final List<Message> _messages = [];
  ChatServiceClient? _client;
  Stream<Message>? _messageStream;

  @override
  void initState() {
    super.initState();
    _initializeClient();
  }

  void _initializeClient() {
    final channel = ClientChannel(
      'localhost',
      port: 50051,
      options: const ChannelOptions(
        credentials: ChannelCredentials.insecure(),
      ),
    );
    _client = ChatServiceClient(channel);
  }

  void _handleConnect() {
    final user = User(name: _usernameController.text);
    _messageStream = _client?.connect(user);

    _messageStream?.listen((message) {
      setState(() {
        _messages.add(message);
      });
    }, onError: (error) {
      print('Error: $error');
    });
  }

  void _handleSubmitted(String text) async {
    if (_client == null || text.isEmpty) return;

    final message = Message()
      ..from = _usernameController.text
      ..content = text;

    _textController.clear();
    await _client!.sendMessage(message);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('gRPC Chat Client')),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _usernameController,
                    decoration:
                        const InputDecoration(hintText: "Enter your username"),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.connect_without_contact),
                  onPressed: _handleConnect,
                ),
              ],
            ),
          ),
          Flexible(
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              reverse: true,
              itemCount: _messages.length,
              itemBuilder: (_, int index) =>
                  _buildMessageEntry(_messages[index]),
            ),
          ),
          const Divider(height: 1.0),
          _buildTextComposer(),
        ],
      ),
    );
  }

  Widget _buildTextComposer() {
    return IconTheme(
      data: IconThemeData(color: Theme.of(context).colorScheme.secondary),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: <Widget>[
            Flexible(
              child: TextField(
                controller: _textController,
                onSubmitted: _handleSubmitted,
                decoration:
                    const InputDecoration.collapsed(hintText: "Send a message"),
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              child: IconButton(
                icon: const Icon(Icons.send),
                onPressed: () => _handleSubmitted(_textController.text),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageEntry(Message message) {
    return ListTile(
      title: Text(message.from),
      subtitle: Text(message.content),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _usernameController.dispose();
    super.dispose();
  }
}
