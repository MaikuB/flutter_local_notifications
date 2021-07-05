//
var sw_reg;
function init_fln(reg) {
    sw_reg = reg;
}

function show(id, title, json) {
    const options = JSON.parse(json);
    sw_reg.showNotification(title,  {
        body: options.body,
    });
}

function periodicallyShow (id, title, body, milisecs) {
    setTimeout(function(){
     sw_reg.showNotification(title,  {
             body: body,
         });
     periodicallyShow(id, title, body, milisecs);
     }, milisecs);
}