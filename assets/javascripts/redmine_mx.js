function randomId() {
  return 'v-' + Math.random().toString(36).slice(-8);
}

function prepareMxDbmsProductVue(data) {
  return new Vue({
    el: '#mx_dbms_product_form',
    data: data,
    methods: {
      addDataType: function() {
        this.$data.data_types.splice(0, 0, { id: randomId(), name: '', sizable: false, scalable: false, use_by_default: false });
      },
      removeDataType: function(dataType) {
        this.$data.data_types.$remove(dataType.$index);
      },
      duplicateDataType: function(dataType) {
        var base = dataType.$data.data_type;
        var newId = randomId();
        this.$data.data_types.splice(dataType.$index + 1, 0, { id: newId, name: '', sizable: base.sizable, scalable: base.scalable, use_by_default: base.use_by_default });
      }
    },
    effects: {
      fadeInOut: {
        enter: function (el, insert, timeout) {
          jQuery(el).animate({ opacity: 0.1 }, 0, function() {
            insert();
          }).animate({ opacity: 1 }, 200);
        },
        leave: function (el, remove, timeout) {
          jQuery(el).animate({ opacity: 0.1 }, 300, function() {
            remove();
          });
        }
      }
    }
  });
}
