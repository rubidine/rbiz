var cart_total_without_shipping = null;
var cart_tax_without_shipping = null;

/*
 * Because IE isn't DOM level 3 compliant
 */
function
cart_element_text(element) {
  if (element.innerText) {
    return element.innerText;
  } else {
    return element.textContent;
  }
}

/*
 * This is going to be keyed in by our radius tag.
 */
var variations = {};

/*
 * This is a helper method when using the dropdown variations.
 * product_id is a number
 */
function
make_selection(product_id) {
  // load variables we need

  // get the tree of variations 
  var data = eval("product_" + product_id + "_data");
  if (!data) {
    alert("missing variable: product_" + product_id + "_keys");
    return;
  }

  // get the tag set names in the order they will be filled out
  var names = eval("product_" + product_id + "_keys");
  if (!names) {
    alert("missing variable: product_" + product_id + "_keys");
    return;
  }

  var price = eval("product_" + product_id + "_price");
  if (!names) {
    alert("missing variable: product_" + product_id + "_price");
    return;
  }

  var d = data;
  var o2 = []
  var options = variations[product_id];

  // if somebody moves a dropdown to '--SELECT--'
  // then d can become undefined, we handle it after we 
  // remove variations farther down the page and
  // remove the buy link
  var cur_opt = null;
  while ((cur_opt = options.shift()) && d) {
    d = d[cur_opt];
    if (d) {
      // show the text field for this option if the option supports it
      if (d.x_has_user_input) {
        var n = names[o2.length];
        n = n.replace(/[^\w]/g, '');
        n = "selection_" + product_id + "_" + n + '_tx';
        var node = document.getElementById( n );
        if (!node) {
          alert("No element: " + n);
          return;
        }
        node.setAttribute('name', "option_input[" + d.option_id + "]");
        node.style.display = '';
      }

      // mark any price adjustment
      if (d.price_adjustment) {
        price = price + d.price_adjustment;
      }

      // move the pointer to the right place to continue walkig the tree
      d = d.children;
    }
    o2.push(cur_opt);
  }
  options = o2;
  variations[product_id] = options;

  // update the price on the page
  var ename = "price_" + product_id;
  var ele = document.getElementById(ename);
  if (ele) {
    while (ele.childNodes.length > 0) {
      ele.removeChild(ele.firstChild);
    }
    ele.appendChild(document.createTextNode(toMoney(price)));
  }

  // If d is a number it is the variation id
  // so we are done and show the buy link.
  // This loop is for other cases -- more variations.
  if (typeof(d) != 'number') {
    // remove any selects that may be on the page that are for options
    // farther down the line
    for (var name_idx = options.length ; name_idx < names.length ; name_idx++) {
      var fn = names[name_idx];
      fn = fn.replace(/[^\w]/g, '');
      fn = 'variation_' + product_id + '_' + fn;
      var fnd = document.getElementById( fn );
      while ( fnd.hasChildNodes() ) {
        fnd.removeChild( fnd.firstChild );
      }
    }

    // this can be customized
    remove_purchase_link(product_id);

    // handle the case that somebody has selected '--SELECT--'
    // now that we have updated options and buy link
    if ( !d ) {
      return;
    }

    names = names[options.length];
    names = names.replace(/[^\w]/g, '');
    names = "variation_" + product_id + "_" + names;
    var node = document.getElementById( names );
    if (!node) {
      alert("No element: " + names);
      return;
    }
    var child = document.createElement('select');
    child.setAttribute('id', names + '_select');
    //child.setAttribute('onChange', fx);
    var nc = document.createElement('option');
    nc.setAttribute('value', '---SELECT---');
    nc.setAttribute('selected', 'true');
    nc.appendChild(document.createTextNode('---SELECT---'));
    child.appendChild(nc);
    for (var o in d) {
      nc = document.createElement('option');
      nc.setAttribute('value', o)
      nc.appendChild(document.createTextNode(o));
      child.appendChild(nc);
    }
    node.appendChild(child);

    var fx = function(){
      var no = [];
      for (var i=0 ; i<options.length; i++) {
        no.push(variations[product_id][i]);
      };
      var sl = document.getElementById(names+'_select');
      no.push(sl.options[sl.selectedIndex].value);
      variations[product_id] = no;
      make_selection(product_id);
    };
    Event.observe( names + '_select' , 'change', fx, false);
  } else {
    make_buy_link(product_id, d);
  }
}

/*
 * This is split out from the main fucnction to be easily overridden
 */
function
make_buy_link(product_id, d) {
  var s_h = document.getElementById( 'disabled_button_' + product_id );
  var s_s = document.getElementById( 'enabled_button_' + product_id );
  var s_i = document.getElementById( 'options_' + product_id );
  if ( s_h && s_s ) {
    s_h.style.display = "none";
    s_s.style.display = "";
    if ( s_i ) {
      s_i.value = d;
    }
  } else {
    alert( "Unable to find link or form buttons to enable for product " + product_id );
  }
}

/*
 * This is also split out to be easily overriden
 */
function
remove_purchase_link(product_id) {
  // remove any purchase link
  var s_s = document.getElementById( 'disabled_button_' + product_id );
  var s_h = document.getElementById( 'enabled_button_' + product_id );
  if ( s_s && s_h ) {
    s_h.style.display = "none";
    s_s.style.display = "";
  }
}

function
toMoney(price) {
  var dollars = Math.floor(price);
  var cents = Math.round((price - dollars) * 100);
  cents = '' + cents;
  while (cents.length < 2) { cents = cents + '0'; }
  return dollars + '.' + cents
}

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
    var re = cart_element_text(gte).strip().match(/^\$?(\d+\.\d\d)/)
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

  var shiptax = 0;
  if (tax_shipping) {
    if (!cart_tax_without_shipping) {
      var tx = $('tax');
      if (!tx) {
        cart_update_grand_total("ERROR - Unable to find tax element");
        return;
      }
      var re = cart_element_text(tx).strip().match(/^\$?(\d+\.\d\d)/);
      if (!re) {
        cart_update_grand_total("ERROR - Unable to parse tax");
        return;
      }
      var fv = parseFloat(re[1]);
      if (!fv) {
        cart_update_grand_total("ERROR - Unable to parse tax float value");
        return;
      }
      cart_tax_without_shipping = fv;
    }
    shiptax = shipcost * tax_rate;
    cart_update_tax(cart_tax_without_shipping + shiptax);
  }
  cart_update_grand_total(shipcost + cart_total_without_shipping + shiptax);
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
cart_update_tax(cost_or_message) {
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

  $('tax').update(cost_or_message);
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
