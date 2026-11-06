import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'communication_service.dart';
import 'calendar_grid.dart';
import 'interview_editor.dart';

class AgendaPage extends StatefulWidget {
  const AgendaPage({super.key,required this.company,this.conversationId});
  final bool company;
  final String? conversationId;
  @override
  State<AgendaPage> createState()=>_AgendaPageState();
}
class _AgendaPageState extends State<AgendaPage> {
  late final _stream=CommunicationService.instance.interviews(widget.company,conversationId:widget.conversationId);
  DateTime? _day;
  bool _showHistory=false;
  @override
  Widget build(BuildContext context)=>SafeArea(child:StreamBuilder<List<Interview>>(stream:_stream,builder:(context,snapshot){
    if(snapshot.hasError)return Center(child:Padding(padding:const EdgeInsets.all(24),child:Text(communicationError(snapshot.error!))));
    if(!snapshot.hasData)return const Center(child:CircularProgressIndicator());
    final all=snapshot.data!;
    final now=DateTime.now();
    final today=DateTime(now.year,now.month,now.day);
    final visible=all.where((i)=>(_showHistory || (i.active && !i.agendaDate.isBefore(today))) && (_day==null || sameDay(i.agendaDate,_day!))).toList();
    return ListView(padding:const EdgeInsets.all(20),children:[
      Text('Agenda de entrevistas',style:Theme.of(context).textTheme.headlineMedium),
      const SizedBox(height:8),const Text('Horários locais do seu dispositivo. Toque em uma entrevista para responder ao convite.'),
      CalendarGrid(selected:_day,events:all.where((i)=>i.active).map((i)=>i.agendaDate).toList(),onSelected:(value)=>setState(()=>_day=value)),
      Wrap(spacing:8,runSpacing:8,children:[
        FilterChip(label:const Text('Todas as datas'),selected:_day==null,onSelected:(_)=>setState(()=>_day=null)),
        FilterChip(label:const Text('Incluir histórico'),selected:_showHistory,onSelected:(value)=>setState(()=>_showHistory=value)),
      ]),
      const SizedBox(height:16),
      if(_day!=null)Text(formatDate(_day!),style:Theme.of(context).textTheme.titleLarge),
      if(visible.isEmpty)const Padding(padding:EdgeInsets.symmetric(vertical:24),child:Text('Nenhuma entrevista para este filtro.')),
      for(final interview in visible)Card(child:ListTile(contentPadding:const EdgeInsets.all(16),
        title:Text(interview.data['title'] as String),
        subtitle:Text('${interview.conversation.otherName(widget.company)}\n${formatMoment(interview.agendaDate)}\n${interview.statusLabel}'),
        isThreeLine:true,trailing:const Icon(Icons.chevron_right),
        onTap:()=>Navigator.push(context,MaterialPageRoute<void>(builder:(_)=>InterviewDetailsPage(id:interview.id,company:widget.company))))),
    ]);
  }));
}

class InterviewDetailsPage extends StatefulWidget {
  const InterviewDetailsPage({super.key,required this.id,required this.company});
  final String id;
  final bool company;
  @override
  State<InterviewDetailsPage> createState()=>_InterviewDetailsPageState();
}
class _InterviewDetailsPageState extends State<InterviewDetailsPage> {
  late final _stream=CommunicationService.instance.interview(widget.id);
  bool _busy=false;
  Future<void> _act(Interview item,String action)async{
    if(_busy)return;
    if(action=='reject'||action=='cancel'){
      final accepted=await showDialog<bool>(context:context,builder:(context)=>AlertDialog(
        title:Text(action=='reject'?'Recusar entrevista?':'Cancelar entrevista?'),
        content:const Text('A outra pessoa verá esta decisão na agenda.'),
        actions:[TextButton(onPressed:()=>Navigator.pop(context,false),child:const Text('Voltar')),
          FilledButton(onPressed:()=>Navigator.pop(context,true),child:Text(action=='reject'?'Recusar':'Cancelar entrevista'))],
      ));
      if(accepted!=true||!mounted)return;
    }
    setState(()=>_busy=true);
    try{await CommunicationService.instance.respond(item,action);
      if(mounted)ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Resposta registrada.')));
    }catch(error){if(mounted)ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(communicationError(error))));}
    finally{if(mounted)setState(()=>_busy=false);}
  }
  @override
  Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:const Text('Entrevista')),
    body:SafeArea(child:StreamBuilder<DocumentSnapshot<Map<String,dynamic>>>(stream:_stream,builder:(context,snapshot){
      if(snapshot.hasError)return Center(child:Text(communicationError(snapshot.error!)));
      if(!snapshot.hasData)return const Center(child:CircularProgressIndicator());
      if(!snapshot.data!.exists)return const Center(child:Text('Entrevista não encontrada.'));
      final item=Interview(snapshot.data!.id,snapshot.data!.data()!);
      final canConfirm=item.start.isAfter(DateTime.now());
      return ListView(padding:const EdgeInsets.all(24),children:[
        Text(item.data['title'] as String,style:Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height:12),Text(item.conversation.otherName(widget.company),style:Theme.of(context).textTheme.titleLarge),
        const SizedBox(height:20),Text(item.statusLabel,style:Theme.of(context).textTheme.titleMedium),
        const SizedBox(height:16),Text('Data: ${formatMoment(item.start)}'),
        Text('Duração estimada: ${item.data['durationMinutes']} minutos'),
        const Text('Horário local do seu dispositivo.'),
        const SizedBox(height:16),SelectableText('Local / link:\n${item.data['location']}'),
        if(item.proposed!=null)...[const SizedBox(height:16),Text('Data sugerida pelo candidato:\n${formatMoment(item.proposed!)}',style:Theme.of(context).textTheme.titleMedium)],
        if((item.data['responseNote'] as String).isNotEmpty)...[const SizedBox(height:16),Text('Observação:\n${item.data['responseNote']}')],
        const SizedBox(height:24),
        if(item.active && !widget.company)...[
          if(item.status=='pending' && canConfirm)FilledButton(onPressed:_busy?null:()=>_act(item,'confirm'),child:const Text('Confirmar presença')),
          if(['pending','confirmed'].contains(item.status))OutlinedButton(onPressed:_busy?null:()=>Navigator.push(context,MaterialPageRoute<void>(builder:(_)=>InterviewEditor(conversation:item.conversation,interview:item,candidateProposal:true))),child:const Text('Pedir alteração de data')),
          if(item.status=='reschedule_requested')const Text('Aguardando a empresa responder à sua sugestão.'),
          TextButton(onPressed:_busy?null:()=>_act(item,'reject'),child:Text(item.status=='confirmed'?'Não poderei comparecer':'Recusar entrevista')),
        ],
        if(item.active && widget.company)...[
          if(item.status=='reschedule_requested' && item.proposed!.isAfter(DateTime.now()))FilledButton(onPressed:_busy?null:()=>_act(item,'acceptProposal'),child:const Text('Confirmar a data sugerida')),
          OutlinedButton(onPressed:_busy?null:()=>Navigator.push(context,MaterialPageRoute<void>(builder:(_)=>InterviewEditor(conversation:item.conversation,interview:item))),child:const Text('Propor outro horário')),
          TextButton(onPressed:_busy?null:()=>_act(item,'cancel'),child:const Text('Cancelar entrevista')),
        ],
        if(!item.active)const Text('Este convite foi encerrado. A empresa pode enviar um novo pela conversa.'),
        if(_busy)const Center(child:CircularProgressIndicator()),
      ]);
    })),
  );
}
