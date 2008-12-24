var spinners = {};

function
create_spinner_img() {
  var img = document.createElement('img');
  img.setAttribute('alt', "Loading Content ...");
  img.setAttribute('src', "/images/cart/spinner.gif");
  img.setAttribute('style', "position: absolute");
  return img;
}

function
show_spinner(for_element) {
  for_element = $(for_element);
  var key = for_element.identify();

  var img = create_spinner_img();
  document.body.appendChild(img);
  Element.clonePosition(img, for_element, {setWidth: false, setHeight: false});

  spinners[key] = img;
  return key;
}

function
hide_spinner(spinner_id) {
  if (spinners[spinner_id]) {
    $(spinners[spinner_id]).remove();
  }
}

function
dispatch(url, options) {
  var sp = options.unset('spinner');
  new Ajax.Updater(
    {success: '_nothing', failure: 'ajax_error'},
    url,
    $H({
      asynchronous: true,
      evalScripts: true,
      onFailure: function() {
        new Effect.BlindDown('ajax_error_container');
        new Effect.Highlight('ajax_error');
        if (sp) {
          hide_spinner(sp);
        }
      },
      onComplete: function() {
        if (sp) {
          hide_spinner(sp);
        }
      }
    }).merge(options).toObject()
  );
}

function
cart_office_process_image_reorder(image_ul, authenticity_token) {
  var position = 1;
  Sortable.sequence(image_ul).each(
    function(thumbnail_id) {
      var spin = show_spinner("thumbnail_" + thumbnail_id);
      thumbnail_id = encodeURIComponent(thumbnail_id);
      var url = '/office/product_images/' + thumbnail_id + '/reorder';
      dispatch(
        url,
        $H({
          parameters: "image[position]=" + encodeURIComponent(position++) +
                      "&authenticity_token=" +
                      encodeURIComponent(authenticity_token),
          spinner: spin
        })
      );
    }
  );
}

function
cart_office_process_image_delete(image_li, authenticity_token) {
  var spin = show_spinner(image_li);
  var image_id = image_li.getAttribute('id').match(/\d+$/);
  var url = "/office/product_images/" + image_id;
  dispatch(
    url,
    $H({
      parameters: {
        _method: 'delete',
        authenticity_token: authenticity_token
      },
      onSuccess: function(request) {
        var ele = $(image_li);
        if (ele.siblings().length == 0) {
          var par = $(ele.parentNode);
          par.remove();
          $('photo_trash').hide();
        } else {
          ele.remove();
        }
      },
      spinner: spin
    })
  );
}

function
cart_office_process_tag_deactivation(activation_id, authenticity_token) {
  var spin = show_spinner("tag_" + activation_id);
  var url = "/office/tag_activations/" + activation_id;
  dispatch(
    url,
    $H({
      parameters: {
        _method: 'delete',
        authenticity_token: encodeURIComponent(authenticity_token)
      },
      spinner: spin
    })
  );
}

function
cart_office_process_option_set_delete(option_set_id, authenticity_token) {
  var spin = show_spinner("option_set_" + option_set_id);
  var url = "/office/option_sets/" + option_set_id;
  dispatch(
    url,
    $H({
      parameters: {
        _method: 'delete',
        authenticity_token: encodeURIComponent(authenticity_token)
      },
      spinner: spin
    })
  );
}

function
cart_office_process_option_delete(option_id, authenticity_token) {
  var spin = show_spinner("option_" + option_id + "_delete_td");
  var url = "/office/options/" + option_id;
  dispatch(
    url,
    $H({
      parameters: {
        _method: 'delete',
        authenticity_token: encodeURIComponent(authenticity_token)
      },
      spinner: spin
    })
  );
}

function
cart_office_process_update_option_selection_quantity(selection_id, auth_token) {
  var element=  $("selection_" + selection_id + "_quantity");
  var spin = show_spinner(element);
  var url = "/office/product_option_selections/" + selection_id;
  dispatch(
    url,
    $H({
      parameters: {
        _method: 'put',
        'product_option_selection[quantity]': $F(element),
        authenticity_token: encodeURIComponent(auth_token)
      },
      spinner: spin
    })
  );
}

function
cart_office_process_update_all_option_selection_quantity(auth_token) {
  var element = $('all_options_quantity');
  var value = $F(element);
  $('option_matrix').getElementsBySelector('input[type=text]').each(
    function(x){
      x.value = value;
      var id = x.getAttribute('id').match(/^selection_(\d+)_quantity$/);
      if (id) {
        cart_office_process_update_option_selection_quantity(id[1], auth_token);
      }
    }
  );
}

function
cart_office_process_show_tags_for_category(category_id){
  var element=  $("tag_set_" + category_id + "_tags");
  var element2=  $("tag_set_" + category_id + "_tag_form");
  if (element.style.display == 'none') {
    element.show();
    var spin = show_spinner(element);
    element2.show();

    var url = "/office/tag_sets/" + category_id + "/tags";
    dispatch(url, $H({ method: 'get', spinner: spin }));
  } else {
    Sortable.destroy(element);
    element.update(document.createTextNode('\u00A0'));
    element.hide();
    element2.hide();
  }
}

function
cart_office_process_edit_category(category_id) {
  var element = $("tag_set_" + category_id);
  var element_children = $("tag_set_children_" + category_id);
  var img = create_spinner_img();
  var div = document.createElement('div');
  div.appendChild(img);
  div.appendChild(document.createElement("br"))
  element.update(div);
  element_children.remove();
  var url = "/office/tag_sets/" + category_id + "/edit";
  dispatch(url, $H({ method: 'get'}));
}

function
cart_office_process_delete_category(category_id, name, authenticity_token) {
  if (confirm("really delete category: " + name)) {
    var element = $("tag_set_" + category_id);
    var element_children = $("tag_set_children_" + category_id);
    var img = create_spinner_img();
    var div = document.createElement('div');
    div.appendChild(img);
    div.appendChild(document.createElement("br"))
    element.update(div);
    element_children.remove();
    var url = "/office/tag_sets/" + category_id;
    dispatch(
      url, 
      $H({ 
        parameters: {
          "authenticity_token": encodeURIComponent(authenticity_token)
        },
        method: 'delete'
      }));
  }
}

function
cart_office_process_tag_reorder(tags_ul, authenticity_token) {
  var position = 1;
  Sortable.sequence(tags_ul).each(
    function(tag_id) {
      var spin = show_spinner("tag_" + tag_id);
      tag_id = encodeURIComponent(tag_id);
      var url = '/office/tags/' + tag_id;
      dispatch(
        url,
        $H({
          parameters: {
            "tag[position]": encodeURIComponent(position++),
            "authenticity_token": encodeURIComponent(authenticity_token)
          },
          spinner: spin,
          method: 'put'
        })
      );
    }
  );
}

function
cart_office_process_edit_tag(tag_id) {
  var element = $("tag_" + tag_id);
  var img = create_spinner_img();
  var div = document.createElement('div');
  div.appendChild(img);
  div.appendChild(document.createElement("br"))
  element.update(div);
  var url = "/office/tags/" + tag_id + "/edit";
  dispatch(url, $H({ method: 'get'}));
}

function
cart_office_process_delete_tag(tag_id, name, authenticity_token) {
  if (confirm("really delete tag: " + name)) {
    var element = $("tag_" + tag_id);
    var img = create_spinner_img();
    var div = document.createElement('div');
    div.appendChild(img);
    div.appendChild(document.createElement("br"))
    element.update(div);
    var url = "/office/tags/" + tag_id;
    dispatch(
      url, 
      $H({
        parameters: {
          "authenticity_token": encodeURIComponent(authenticity_token)
        }, 
        method: 'delete'
      }));
  }
}

function
cart_office_never_effective(checkbox) {
  var emt = document.getElementById("product_effective_on_wrapper");
  if (checkbox.checked) {
    emt.style.display = 'none';
  } else {
    emt.style.display = '';
  }
}

function
cart_office_always_effective(checkbox) {
  var emt = document.getElementById("product_ineffective_on_wrapper");
  if (checkbox.checked) {
    emt.style.display = 'none';
  } else {
    emt.style.display = '';
  }
}

function
cart_office_unlimited_quantity(checkbox, id) {
  var emt = document.getElementById(id + "_quantity_wrapper");
  if (checkbox.checked) {
    emt.style.display = 'none';
  } else {
    emt.style.display = '';
  }
}
