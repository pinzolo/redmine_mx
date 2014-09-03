var mx = {
  randomId: function() {
    return 'v-' + Math.random().toString(36).slice(-8);
  },
  findById: function(collection, id) {
    if (!id) { return null; }
    if (!collection) { return null; }

    var obj;
    collection.forEach(function(item) {
      if (item.id.toString() === id.toString()) {
        obj = item;
      }
    });
    return obj;
  },
  isPresent: function(text) {
    console.log('isPresent');
    return text && text.length > 0;
  },
  isEmpty: function(text) {
    console.log('isEmpty');
    return !this.isPresent(text);
  },
  unselectedColumnIds: function(columns, selectedColumnIds, $) {
    var allColumnIds = $.map(columns, function(column) { return column.id.toString(); });
    return $.grep(allColumnIds, function(columnId) {
      return $.inArray(columnId.toString(), selectedColumnIds) < 0;
    });
  }
};

function prepareMxDbmsProductVue(data) {
  return new Vue({
    el: '#mx_dbms_product_form',
    data: data,
    methods: {
      addDataType: function() {
        this.data_types.push({ id: mx.randomId() });
      },
      removeDataType: function(dataType) {
        this.data_types.$remove(dataType.$index);
      },
      insertDataType: function(dataType) {
        this.data_types.splice(dataType.$index, 0, { id: mx.randomId() });
      },
      classFor: function(obj, prop) {
        return obj.errors && obj.errors[prop] ? 'mx-error' : '';
      }
    }
  });
}

function prepareMxColumnSetVue(data) {
  return new Vue({
    el: '#mx_column_set_form',
    data: data,
    methods: {
      addHeaderColumn: function() {
        this.header_columns.push({ id: mx.randomId() });
      },
      addFooterColumn: function() {
        this.footer_columns.push({ id: mx.randomId() });
      },
      removeHeaderColumn: function(column) {
        this.header_columns.$remove(column.$index);
      },
      removeFooterColumn: function(column) {
        this.footer_columns.$remove(column.$index);
      },
      classFor: function(obj, prop) {
        return obj.errors && obj.errors[prop] ? 'mx-error' : '';
      },
      getDataType: function(dataTypeId) {
        return mx.findById(this.data_types, dataTypeId);
      },
      sizeEditable: function(obj) {
        var dataType = this.getDataType(obj.$data.column.data_type_id);
        return dataType && dataType.sizable;
      },
      scaleEditable: function(obj) {
        var dataType = this.getDataType(obj.$data.column.data_type_id);
        return dataType && dataType.scalable;
      },
      changeDataType: function(obj) {
        if (!this.sizeEditable(obj)) {
          obj.$data.column.size = null;
        }
        if (!this.scaleEditable(obj)) {
          obj.$data.column.scale = null;
        }
      }
    }
  });
}

function prepareMxTableVue(data, $) {
  $('#mx-index-edit').hide();
  return new Vue({
    el: '#mx_table_form',
    data: data,
    computed: {
      headerColumns: function() {
        var columnSet = mx.findById(this.column_sets, this.column_set_id);
        return columnSet ? columnSet.header_columns : [];
      },
      footerColumns: function() {
        var columnSet = mx.findById(this.column_sets, this.column_set_id);
        return columnSet ? columnSet.footer_columns : [];
      },
      columns: function() {
        return $.merge($.merge($.merge([], this.headerColumns), this.table_columns), this.footerColumns);
      }
    },
    methods: {
      addColumn: function() {
        this.table_columns.push({ id: mx.randomId() });
      },
      insertColumn: function(column) {
        this.table_columns.splice(column.$index, 0, { id: mx.randomId() });
      },
      removeColumn: function(column) {
        this.table_columns.$remove(column.$index);
        var pkIndex = $.inArray(column.$data.column.id.toString(), this.primary_key.column_ids);
        if (pkIndex > -1) {
          this.primary_key.column_ids.$remove(pkIndex);
        }
      },
      upColumn: function(column) {
        this.table_columns.$remove(column.$index);
        this.table_columns.splice(column.$index - 1, 0, column.$data.column);
      },
      downColumn: function(column) {
        this.table_columns.$remove(column.$index);
        this.table_columns.splice(column.$index + 1, 0, column.$data.column);
      },
      classFor: function(obj, prop) {
        return obj.errors && obj.errors[prop] ? 'mx-error' : '';
      },
      getColumn: function(columnId) {
        return mx.findById(this.columns, columnId);
      },
      getDataType: function(dataTypeId) {
        return mx.findById(this.data_types, dataTypeId);
      },
      sizeEditable: function(obj) {
        var dataType = this.getDataType(obj.$data.column.data_type_id);
        return dataType && dataType.sizable;
      },
      scaleEditable: function(obj) {
        var dataType = this.getDataType(obj.$data.column.data_type_id);
        return dataType && dataType.scalable;
      },
      changeDataType: function(obj) {
        if (!this.sizeEditable(obj)) {
          obj.$data.column.size = null;
        }
        if (!this.scaleEditable(obj)) {
          obj.$data.column.scale = null;
        }
      },
      isPrimaryKeyColumn: function(column) {
        return $.inArray(column.$data.column.id.toString(), this.primary_key.column_ids) > -1;
      },
      getPrimaryKeyColumnPosition: function(column) {
        var primaryKeyColumnIndex = $.inArray(column.$data.column.id.toString(), this.primary_key.column_ids);
        return primaryKeyColumnIndex === -1 ? '' : (primaryKeyColumnIndex + 1).toString();
      },
      togglePrimaryKeyColumn: function(column) {
        var primaryKeyColumnIndex = $.inArray(column.$data.column.id.toString(), this.primary_key.column_ids);
        if (primaryKeyColumnIndex === -1) {
          this.primary_key.column_ids.push(column.$data.column.id.toString());
        } else {
          this.primary_key.column_ids.$remove(primaryKeyColumnIndex);
        }
      },
      newIndex: function() {
        var allColumnIds = $.map(this.columns, function(column) { return column.id.toString(); });
        this.editingIndex = { id: mx.randomId(), unselectedColumnIds: allColumnIds, columnIds: [] };
        $('#mx-index-edit').animate({ opacity: 'show' }, { duration: 300 });
        $('#mx-new-index-link').hide();
      },
      editIndex: function(index) {
        this.editingIndex.id = index.$data.index.id;
        this.editingIndex.name = index.$data.index.name;
        this.editingIndex.columnIds = index.$data.index.column_ids;
        this.editingIndex.unique = index.$data.index.unique;
        this.editingIndex.condition = index.$data.index.condition;
        this.editingIndex.comment = index.$data.index.comment;
        var selectedColumnIds = this.editingIndex ? this.editingIndex.columnIds : [];
        this.editingIndex.unselectedColumnIds = mx.unselectedColumnIds(this.columns, selectedColumnIds, $);
        $('#mx-index-edit').animate({ opacity: 'show' }, { duration: 300 });
        $('#mx-new-index-link').hide();
      },
      removeIndex: function(index) {
        this.indices.$remove(index.$index);
      },
      addToIndexColumns: function(columnId) {
        this.editingIndex.columnIds.push(columnId.$data.columnId);
        var selectedColumnIds = this.editingIndex ? this.editingIndex.columnIds : [];
        this.editingIndex.unselectedColumnIds = mx.unselectedColumnIds(this.columns, selectedColumnIds, $);
      },
      removeFromIndexColumns: function(columnId) {
        this.editingIndex.columnIds.$remove(columnId.$index);
        var selectedColumnIds = this.editingIndex ? this.editingIndex.columnIds : [];
        this.editingIndex.unselectedColumnIds = mx.unselectedColumnIds(this.columns, selectedColumnIds, $);
      },
      upIndexColumn: function(columnId) {
        this.editingIndex.columnIds.$remove(columnId.$index);
        this.editingIndex.columnIds.splice(columnId.$index - 1, 0, columnId.$data.columnId);
      },
      downIndexColumn: function(columnId) {
        this.editingIndex.columnIds.$remove(columnId.$index);
        this.editingIndex.columnIds.splice(columnId.$index + 1, 0, columnId.$data.columnId);
      },
      cancelIndexEditing: function() {
        $('#mx-index-edit').animate({ opacity: 'hide' }, { duration: 300 });
        $('#mx-new-index-link').show();
        this.editingIndex = { id: mx.randomId(), columnIds: [] };
      },
      saveIndex: function() {
        $('#mx-index-edit').animate({ opacity: 'hide' }, { duration: 300 });
        $('#mx-new-index-link').show();
        var savedIndexIds = $.map(this.indices, function(index) { return index.id.toString(); });
        var indexPosition = $.inArray(this.editingIndex.id.toString(), savedIndexIds);
        var data = {
          id: this.editingIndex.id,
          name: this.editingIndex.name,
          column_ids: this.editingIndex.columnIds,
          unique: this.editingIndex.unique,
          condition: this.editingIndex.condition,
          comment: this.editingIndex.comment
        };
        if (indexPosition > -1) {
          this.indices.$set(indexPosition, data);
        } else {
          this.indices.push(data);
        }
        this.editingIndex = { id: mx.randomId(), columnIds: [] };
      },
      enumColumnNames: function(columnIds) {
        if (!columnIds) {
          return '';
        }
        var columns = this.columns;
        var physicalNames = $.map(columnIds, function(columnId) {
          return mx.findById(columns, columnId).physical_name;
        });
        return physicalNames.join(', ');
      }
    }
  });
}
