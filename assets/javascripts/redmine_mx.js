function randomId() {
  return 'v-' + Math.random().toString(36).slice(-8);
}

function prepareMxDbmsProductVue(data) {
  return new Vue({
    el: '#mx_dbms_product_form',
    data: data
  });
}
