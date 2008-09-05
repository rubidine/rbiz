var cart_total_without_shipping = null;

function
cart_compute_total() {
  var se = $('shipping_method_id');
  if (!se) {
    cart_update_grand_total("ERROR - Unable to find shipping element");
    return;
  }
  if (!cart_total_without_shipping) {
    var gte = $('grand_total');
    if (!gte) {
      cart_update_grand_total("ERROR - Unable to find grand total element");
      return;
    }
    var re = gte.textContent.strip().match(/^\$?(\d+\.\d\d)/)
    if (!re) {
      cart_update_grand_total("ERROR - Unable to parse total");
      return;
    }
    var fv = parseFloat(re[1]);
    if (!fv) {
      cart_update_grand_total("ERROR - Unable to parse float value");
      return;
    }
    cart_total_without_shipping = fv;
  }


  var opt = se.options[se.selectedIndex];
  var input = $('payment_shipping_key');
  if (input) {
    input.value = opt.value;
  }
  var re = opt.text.match(/^(\d+\.\d\d) - /);
  if (!re) {
    cart_update_grand_total("ERROR - Unable match on shipping cost");
    return;
  }
  var shipcost = parseFloat(re[1]);
  if (!shipcost) {
    cart_update_grand_total("ERROR - Unable to parse shiping cost float");
    return;
  }
  cart_update_grand_total(shipcost + cart_total_without_shipping);
}

function
cart_update_grand_total(cost_or_message) {
  if (typeof(cost_or_message) == "string") {
    cart_disable_finalize_button();
  }
  if (typeof(cost_or_message) == "number") {
    cost_or_message = cost_or_message * 100;
    cost_or_message = cost_or_message.round();
    var dollars = parseInt(cost_or_message / 100);
    var cents = parseInt(cost_or_message - (dollars * 100)) + "";
    while (cents.length < 2) { cents = "0" + cents; }
    cost_or_message = dollars + "." + cents;
  }

  $('grand_total').update(cost_or_message);
}

function
cart_disable_finalize_button() {
  var emt = $('finalize_button');
  if (emt) {
    emt .disable();
  }
}

function
cart_select_payment_type() {
  var se = $('payment_method');
  if (!se) {
    alert("Unable to find element 'payment_type', please contact site owner");
    return;
  }
  var opt_array = $A(se.options);
  if (opt_array.length == 2) {
    cart_show_payment_type(opt_array[1].value);
    se.selectedIndex = 1;
    var ps = $('payment_selector');
    if (ps) {
      ps.hide();
    }
  } else {
    opt_array.each(
      function(opt, idx){
        if (se.selectedIndex == idx) {
          cart_show_payment_type(opt.value);
        } else {
          cart_hide_payment_type(opt.value);
        }
      }
    );
  }
}

function
cart_show_payment_type(key) {
  var element = $("processor_" + key);
  if (element) {
    element.show();
  }
}

function
cart_hide_payment_type(key) {
  var element = $("processor_" + key);
  if (element) {
    element.hide();
  }
}

function
cart_register_onload(callback) {
  Event.observe(window, 'load', callback);
}
