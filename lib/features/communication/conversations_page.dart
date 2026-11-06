import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'communication_service.dart';
import 'agenda_page.dart';
import 'interview_editor.dart';

class ConversationsPage extends StatefulWidget {
  const ConversationsPage({super.key,required this.company});
  final bool company;
  @override
  State<ConversationsPage> createState()=>_ConversationsPageState();
}
class _ConversationsPageState extends State<ConversationsPage> {
  late final _stream=CommunicationService.instance.conversations(widget.company);
  @override
  Widget build(BuildContext context)=>SafeArea(child:Padding(padding:const EdgeInsets.all(20),child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
    Text('Conversas',style:Theme.of(context).textTheme.headlineMedium),const SizedBox(height:16),
    Expanded(child:StreamBuilder<List<Conversation>>(stream:_stream,builder:(context,snapshot){
      if(snapshot.hasError) return Center(child:Text(communicationError(snapshot.error!)));
      if(!snapshot.hasData) return const Center(child:CircularProgressIndicator());
      final items=snapshot.data!;
      if(items.isEmpty) return Center(child:Text(widget.company ? 'Abra um currículo na aba Candidatos e toque em Conversar.' : 'Quando uma empresa iniciar uma conversa, ela aparecerá aqui.',textAlign:TextAlign.center));
      return ListView.separated(itemCount:items.length,separatorBuilder:(_,_)=>const Divider(),itemBuilder:(context,index){
        final item=items[index];
        return ListTile(leading:const Icon(Icons.chat_bubble_outline),title:Text(item.otherName(widget.company)),
          subtitle:const Text('Abrir conversa'),trailing:const Icon(Icons.chevron_right),
          onTap:()=>Navigator.push(context,MaterialPageRoute<void>(builder:(_)=>ChatPage(conversation:item,company:widget.company))));
      });
    })),
  ])));
}

class StartConversationButton extends StatefulWidget {
  const StartConversationButton({super.key,required this.candidateId});
  final String candidateId;
  @override
  State<StartConversationButton> createState()=>_StartConversationButtonState();
}
class _StartConversationButtonState extends State<StartConversationButton> {
  bool _busy=false;
  @override
  Widget build(BuildContext context)=>FilledButton.icon(icon:const Icon(Icons.chat_outlined),label:Text(_busy?'Abrindo...':'Conversar'),onPressed:_busy?null:() async {
    setState(()=>_busy=true);
    try {
      final conversation=await CommunicationService.instance.openConversation(widget.candidateId);
      if(context.mounted) await Navigator.push(context,MaterialPageRoute<void>(builder:(_)=>ChatPage(conversation:conversation,company:true)));
    } catch(error) { if(context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(communicationError(error)))); }
    finally { if(mounted) setState(()=>_busy=false); }
  });
}

class ChatPage extends StatefulWidget {
  const ChatPage({super.key,required this.conversation,required this.company});
  final Conversation conversation;
  final bool company;
  @override
  State<ChatPage> createState()=>_ChatPageState();
}
class _ChatPageState extends State<ChatPage> {
  final _text=TextEditingController();
  bool _sending=false;
  int _limit=50;
  String? _messageId, _attemptText;
  late Stream<QuerySnapshot<Map<String,dynamic>>> _messages=CommunicationService.instance.messages(widget.conversation.id,_limit);
  @override
  void dispose(){_text.dispose();super.dispose();}
  Future<void> _send() async {
    final text=_text.text.trim();
    if(_sending || text.isEmpty) return;
    if(text.length>3000) return;
    if(_attemptText != text){_messageId=CommunicationService.instance.newMessageId(widget.conversation.id);_attemptText=text;}
    setState(()=>_sending=true);
    try {
      await CommunicationService.instance.sendMessage(widget.conversation.id,_messageId!,text);
      if(mounted){_text.clear();_messageId=null;_attemptText=null;}
    } catch(error){if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(communicationError(error))));}
    finally{if(mounted)setState(()=>_sending=false);}
  }
  @override
  Widget build(BuildContext context)=>Scaffold(
    appBar:AppBar(title:Text(widget.conversation.otherName(widget.company))),
    body:SafeArea(child:Column(children:[
      Padding(padding:const EdgeInsets.symmetric(horizontal:16,vertical:8),child:Wrap(spacing:12,runSpacing:8,children:[
        if(widget.company) FilledButton.icon(icon:const Icon(Icons.event_available),label:const Text('Marcar entrevista'),
          onPressed:()=>Navigator.push(context,MaterialPageRoute<void>(builder:(_)=>InterviewEditor(conversation:widget.conversation)))),
        OutlinedButton.icon(icon:const Icon(Icons.calendar_month),label:const Text('Ver entrevistas'),
          onPressed:()=>Navigator.push(context,MaterialPageRoute<void>(builder:(_)=>Scaffold(appBar:AppBar(title:const Text('Entrevistas desta conversa')),
            body:AgendaPage(company:widget.company,conversationId:widget.conversation.id))))),
      ])),
      _ChatInterviewSummary(conversationId:widget.conversation.id,company:widget.company),
      Expanded(child:StreamBuilder<QuerySnapshot<Map<String,dynamic>>>(stream:_messages,builder:(context,snapshot){
        if(snapshot.hasError) return Center(child:Text(communicationError(snapshot.error!)));
        if(!snapshot.hasData) return const Center(child:CircularProgressIndicator());
        final docs=snapshot.data!.docs;
        if(docs.isEmpty) return const Center(child:Text('Envie uma mensagem para iniciar a conversa.'));
        return ListView.builder(reverse:true,padding:const EdgeInsets.all(16),itemCount:docs.length+(docs.length>=_limit?1:0),itemBuilder:(context,index){
          if(index==docs.length) return TextButton(onPressed:()=>setState((){_limit+=50;_messages=CommunicationService.instance.messages(widget.conversation.id,_limit);}),child:const Text('Carregar mensagens anteriores'));
          final data=docs[index].data();
          final mine=data['senderId']==CommunicationService.instance.uid;
          final date=(data['createdAt'] as Timestamp?)?.toDate().toLocal();
          return Align(alignment:mine?Alignment.centerRight:Alignment.centerLeft,child:Container(
            constraints:BoxConstraints(maxWidth:MediaQuery.sizeOf(context).width*0.8),
            margin:const EdgeInsets.only(bottom:12),padding:const EdgeInsets.all(14),
            decoration:BoxDecoration(color:mine?Theme.of(context).colorScheme.primaryContainer:Theme.of(context).colorScheme.surfaceContainerHighest,borderRadius:BorderRadius.circular(16)),
            child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
              Text(mine?'Você':widget.conversation.otherName(widget.company),style:Theme.of(context).textTheme.labelMedium),
              const SizedBox(height:4),SelectableText(data['text'] as String),
              if(date!=null) Padding(padding:const EdgeInsets.only(top:6),child:Text(formatMoment(date),style:Theme.of(context).textTheme.labelSmall)),
            ])));
        });
      })),
      Padding(padding:const EdgeInsets.all(12),child:Row(crossAxisAlignment:CrossAxisAlignment.end,children:[
        Expanded(child:TextField(controller:_text,enabled:!_sending,minLines:1,maxLines:4,maxLength:3000,
          decoration:const InputDecoration(labelText:'Mensagem',counterText:''))),
        const SizedBox(width:8),IconButton.filled(tooltip:'Enviar mensagem',onPressed:_sending?null:_send,
          icon:_sending?const SizedBox(width:22,height:22,child:CircularProgressIndicator(strokeWidth:2)):const Icon(Icons.send)),
      ])),
    ])),
  );
}

class _ChatInterviewSummary extends StatefulWidget {
  const _ChatInterviewSummary({required this.conversationId,required this.company});
  final String conversationId;
  final bool company;
  @override
  State<_ChatInterviewSummary> createState()=>_ChatInterviewSummaryState();
}
class _ChatInterviewSummaryState extends State<_ChatInterviewSummary> {
  late final _stream=CommunicationService.instance.interviews(widget.company,conversationId:widget.conversationId);
  @override
  Widget build(BuildContext context)=>StreamBuilder<List<Interview>>(stream:_stream,builder:(context,snapshot){
    if(snapshot.hasError)return Padding(padding:const EdgeInsets.all(12),child:Text(communicationError(snapshot.error!)));
    final interviews=snapshot.data??[];
    if(interviews.isEmpty)return const SizedBox.shrink();
    final pending=interviews.where((i)=>i.status==(widget.company?'reschedule_requested':'pending')).length;
    return Padding(padding:const EdgeInsets.symmetric(horizontal:16,vertical:4),child:Text(
      pending>0?'$pending convite(s) aguardando sua resposta. Toque em Ver entrevistas.':'${interviews.length} entrevista(s) nesta conversa. Acompanhe em Ver entrevistas.',
      style:Theme.of(context).textTheme.bodyMedium));
  });
}
