$(document).ready(function() {
	if($('#mobile_calendar').length > 0){
		ret="";
		data_url=$('#mobile_calendar').data('url') || $('#mobile_calendar').data('url');
		$.ajax(data_url,{dataType: 'json',success:function(data,status,xhr){
			if(data.length==0){
				$('#mobile_calendar').html("There are no Assignments for today");	
			}else{
				data.sort(function(a,b){
					if(a['start']!=b['start']){
						return a['start']>b['start'];
					}else{
						return a['title']>b['title'];
					}
				});
				s="";
				s+="<table>";
				$.each(data,function(i,assignment){
					s+="<tr style='background:"+assignment['color']+";color:"+assignment['textColor']+"'>";
					s+="<td><a href='"+assignment['url_view']+"' style='color:"+assignment['textColor']+"'>"+assignment['qrid_name']+"</a></td>";
					s+="<td>"+assignment['start_at_dt']+"</td>";
					s+="<td>"+assignment['site']+"</td>";
					s+="<td>"+assignment['assignee']+"</td>";
					s+="<td>"+assignment['work_type']+"</td>";
					s+="<td>"+assignment['status']+"</td>";
					s+="</tr>";
				});
				s+="</table>";
				$('#mobile_calendar').html(s);
			}
		}});
	}
});
