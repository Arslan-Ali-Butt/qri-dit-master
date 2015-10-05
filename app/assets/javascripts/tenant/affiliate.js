function for_affiliates(task_url,check,type){
    obj={}
    obj[type]={'for_affiliates':check.checked}
  $.ajax({
    url: task_url,
    type:'patch',
    data: obj
  })
}