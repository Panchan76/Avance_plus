import 'package:flutter/material.dart';

bool sameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;
class CalendarGrid extends StatefulWidget {
  const CalendarGrid({super.key, required this.onSelected, this.selected, this.events = const [], this.futureOnly = false});
  final ValueChanged<DateTime> onSelected;
  final DateTime? selected;
  final List<DateTime> events;
  final bool futureOnly;
  @override
  State<CalendarGrid> createState() => _CalendarGridState();
}
class _CalendarGridState extends State<CalendarGrid> {
  late DateTime _month = DateTime((widget.selected ?? DateTime.now()).year, (widget.selected ?? DateTime.now()).month);
  static const months = ['Janeiro','Fevereiro','Março','Abril','Maio','Junho','Julho','Agosto','Setembro','Outubro','Novembro','Dezembro'];
  @override
  Widget build(BuildContext context) {
    final first = _month.weekday % 7;
    final days = DateTime(_month.year,_month.month+1,0).day;
    final cells = ((first + days) / 7).ceil() * 7;
    final now = DateTime.now();
    final today = DateTime(now.year,now.month,now.day);
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Row(children: [
        IconButton(tooltip:'Mês anterior', onPressed: () => setState(() => _month = DateTime(_month.year,_month.month-1)), icon:const Icon(Icons.chevron_left)),
        Expanded(child: Text('${months[_month.month-1]} ${_month.year}',textAlign:TextAlign.center,style:Theme.of(context).textTheme.titleMedium)),
        IconButton(tooltip:'Próximo mês', onPressed: () => setState(() => _month = DateTime(_month.year,_month.month+1)), icon:const Icon(Icons.chevron_right)),
      ]),
      Row(children: [for(final day in ['D','S','T','Q','Q','S','S']) Expanded(child:Text(day,textAlign:TextAlign.center))]),
      const SizedBox(height:8),
      GridView.builder(shrinkWrap:true,physics:const NeverScrollableScrollPhysics(),itemCount:cells,
        gridDelegate:const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount:7,mainAxisExtent:52),
        itemBuilder:(context,index) {
          final day = index-first+1;
          if(day<1 || day>days) return const SizedBox.shrink();
          final date = DateTime(_month.year,_month.month,day);
          final disabled = widget.futureOnly && date.isBefore(today);
          final selected = widget.selected != null && sameDay(date,widget.selected!);
          final count = widget.events.where((event)=>sameDay(event,date)).length;
          return Semantics(button:true,selected:selected,label:'$day de ${months[_month.month-1]}, $count entrevistas',
            child: Padding(padding:const EdgeInsets.all(2),child: Material(
              color:selected ? Theme.of(context).colorScheme.primaryContainer : Colors.transparent,
              borderRadius:BorderRadius.circular(12),
              child: InkWell(borderRadius:BorderRadius.circular(12),onTap:disabled ? null : ()=>widget.onSelected(date),
                child:Column(mainAxisAlignment:MainAxisAlignment.center,children:[
                  Text('$day',style:TextStyle(color:disabled ? Colors.grey : null,fontWeight:sameDay(today,date)?FontWeight.bold:null)),
                  if(count>0) Container(width:6,height:6,decoration:BoxDecoration(color:Theme.of(context).colorScheme.primary,shape:BoxShape.circle)),
                ])),
            )));
        }),
    ]);
  }
}

Future<DateTime?> selectDateTime(BuildContext context, DateTime initial) async {
  final now = DateTime.now();
  DateTime selected = initial.isAfter(now) ? initial : now;
  final date = await showDialog<DateTime>(context:context,builder:(context)=>StatefulBuilder(builder:(context,setLocal)=>AlertDialog(
    title:const Text('Escolha a data'),
    content:SizedBox(width:360,child:SingleChildScrollView(child:CalendarGrid(selected:selected,futureOnly:true,onSelected:(value)=>setLocal(()=>selected=value)))),
    actions:[TextButton(onPressed:()=>Navigator.pop(context),child:const Text('Cancelar')),
      FilledButton(onPressed:()=>Navigator.pop(context,selected),child:const Text('Escolher horário'))],
  )));
  if(date==null || !context.mounted) return null;
  final time = await showTimePicker(context:context,initialTime:TimeOfDay.fromDateTime(initial),
    helpText:'Escolha o horário',cancelText:'Cancelar',confirmText:'Confirmar',hourLabelText:'Hora',minuteLabelText:'Minuto',
    builder:(context,child)=>MediaQuery(data:MediaQuery.of(context).copyWith(alwaysUse24HourFormat:true),child:child!));
  if(time==null) return null;
  return DateTime(date.year,date.month,date.day,time.hour,time.minute);
}
