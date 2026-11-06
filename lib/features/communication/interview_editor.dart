import 'package:flutter/material.dart';
import 'communication_service.dart';
import 'calendar_grid.dart';

class InterviewEditor extends StatefulWidget {
  const InterviewEditor({super.key, required this.conversation, this.interview, this.candidateProposal=false});
  final Conversation conversation;
  final Interview? interview;
  final bool candidateProposal;
  @override
  State<InterviewEditor> createState()=>_InterviewEditorState();
}
class _InterviewEditorState extends State<InterviewEditor> {
  final _form=GlobalKey<FormState>();
  final _title=TextEditingController(text:'Entrevista profissional');
  final _location=TextEditingController(),_note=TextEditingController();
  late final String _id=CommunicationService.instance.newInterviewId();
  late DateTime _start=widget.interview?.start.isAfter(DateTime.now())==true ? widget.interview!.start : DateTime(DateTime.now().year,DateTime.now().month,DateTime.now().day+1,9);
  int _duration=30;
  bool _busy=false;
  bool get _creating=>widget.interview==null;
  @override
  void dispose(){_title.dispose();_location.dispose();_note.dispose();super.dispose();}
  Future<void> _save() async {
    if(_busy || !_form.currentState!.validate())return;
    if(!_start.isAfter(DateTime.now())){_message('Escolha uma data e um horário futuros.');return;}
    setState(()=>_busy=true);
    try{
      if(_creating){
        await CommunicationService.instance.invite(id:_id,conversation:widget.conversation,title:_title.text,location:_location.text,start:_start,duration:_duration);
      }else{
        await CommunicationService.instance.respond(widget.interview!,widget.candidateProposal?'propose':'offer',date:_start,note:_note.text);
      }
      if(mounted){_message(_creating?'Convite enviado. Acompanhe na Agenda ou em Ver entrevistas.':'Proposta enviada. Aguarde a resposta da outra pessoa.');Navigator.pop(context);}
    }catch(error){if(mounted)_message(communicationError(error));}
    finally{if(mounted)setState(()=>_busy=false);}
  }
  void _message(String message)=>ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(message)));
  @override
  Widget build(BuildContext context)=>PopScope(canPop:!_busy,child:Scaffold(
    appBar:AppBar(title:Text(_creating?'Marcar entrevista':widget.candidateProposal?'Sugerir outra data':'Propor novo horário')),
    body:SafeArea(child:SingleChildScrollView(padding:const EdgeInsets.all(24),child:Form(key:_form,child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
      Text(widget.candidateProposal?'A empresa precisará confirmar a data que você sugerir.':'O candidato precisará confirmar se pode comparecer.'),
      const SizedBox(height:20),
      if(_creating)...[
        TextFormField(controller:_title,enabled:!_busy,maxLength:120,decoration:const InputDecoration(labelText:'Título / cargo da entrevista'),
          validator:(value)=>(value??'').trim().length<3?'Informe o título.':null),
        const SizedBox(height:12),
        TextFormField(controller:_location,enabled:!_busy,maxLength:500,maxLines:3,
          decoration:const InputDecoration(labelText:'Endereço ou link da entrevista',alignLabelWithHint:true),
          validator:(value)=>(value??'').trim().length<3?'Informe onde será a entrevista.':null),
        const SizedBox(height:12),
        DropdownButtonFormField<int>(initialValue:_duration,decoration:const InputDecoration(labelText:'Duração estimada'),
          items:[for(final value in [15,30,45,60,90,120])DropdownMenuItem(value:value,child:Text('$value minutos'))],
          onChanged:_busy?null:(value)=>setState(()=>_duration=value!)),
      ]else...[
        Text(widget.interview!.data['title'] as String,style:Theme.of(context).textTheme.titleLarge),
        const SizedBox(height:8),Text('Horário anterior: ${formatMoment(widget.interview!.start)}'),
      ],
      const SizedBox(height:24),
      Text('Data e horário: ${formatMoment(_start)}',style:Theme.of(context).textTheme.titleMedium),
      const SizedBox(height:8),const Text('Horário local do seu dispositivo. Confira também o endereço ou link combinado.'),
      const SizedBox(height:12),
      OutlinedButton.icon(icon:const Icon(Icons.calendar_month),label:const Text('Escolher data e horário'),onPressed:_busy?null:()async{
        final selected=await selectDateTime(context,_start);
        if(selected!=null && mounted)setState(()=>_start=selected);
      }),
      if(!_creating)...[
        const SizedBox(height:16),TextFormField(controller:_note,enabled:!_busy,maxLength:1000,maxLines:3,
          decoration:const InputDecoration(labelText:'Observação (opcional)',alignLabelWithHint:true)),
      ],
      const SizedBox(height:24),
      FilledButton(onPressed:_busy?null:_save,child:Text(_busy?'Enviando...':_creating?'Enviar convite':'Enviar proposta de horário')),
    ])))),
  ));
}
