var mx = {
  randomId: function() {
    return 'v-' + Math.random().toString(36).slice(-8);
  },
  isSame: function(a, b) {
    if (a && b) {
      return a.toString() === b.toString();
    }

    return a === b;
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
    return text && text.length > 0;
  },
  isEmpty: function(text) {
    return !this.isPresent(text);
  },
  unselectedColumnIds: function(allColumns, selectedColumnIds) {
    var allColumnIds = $.map(allColumns, function(column) { return column.id.toString(); });
    return $.grep(allColumnIds, function(columnId) {
      return $.inArray(columnId.toString(), selectedColumnIds) < 0;
    });
  },
  foreignKeyColumnIds: function(foreignKey) {
    return $.map(foreignKey.relations, function(relation) { return relation.column_id; });
  },
  initEditingIndex: function(editingIndex) {
    editingIndex.id = this.randomId();
    editingIndex.name = '';
    editingIndex.columnIds = [];
    editingIndex.unique = false;
    editingIndex.condition = '';
    editingIndex.comment = '';
  },
  initEditingForeignKey: function(vueModel) {
    vueModel.refTableColumns = [];
    vueModel.editingForeignKey.id = this.randomId();
    vueModel.editingForeignKey.name = '';
    vueModel.editingForeignKey.ref_table_id = '';
    vueModel.editingForeignKey.relations = [];
    vueModel.editingForeignKey.comment = '';
  },
  loadRefTableColumns: function(vueModel, refTalbleId, func) {
    $.ajax({
      type: 'GET',
      url: $('#load_ref_table_columns_base_path').val() + '/' + refTalbleId + '/columns'
    }).done(function(columnsData) {
      vueModel.refTableColumns = columnsData;
    }).done(function() {
      if (func) { func(); }
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
  var controllMxTableSubmitCommandsDisplay = function() {
    $('#mx-table-submit-commands').toggle($('#mx-index-edit').is(':hidden') && $('#mx-foreign-key-edit').is(':hidden'));
  };
  var showMxIndexEdit = function() {
    $('#mx-new-index-link').hide();
    $('#mx-index-edit').animate({ opacity: 'show' }, { duration: 300 }).promise().done(controllMxTableSubmitCommandsDisplay);
  };
  var hideMxIndexEdit = function() {
    $('#mx-index-edit').animate({ opacity: 'hide' }, { duration: 300 }).promise().done(function() {
      $('#mx-new-index-link').show();
      controllMxTableSubmitCommandsDisplay();
    });
  };
  var showMxForeignKeyEdit = function() {
    $('#mx-new-foreign-key-link').hide();
    $('#mx-foreign-key-edit').animate({ opacity: 'show' }, { duration: 300 }).promise().done(controllMxTableSubmitCommandsDisplay);
  };
  var hideMxForeignKeyEdit = function() {
    $('#mx-foreign-key-edit').animate({ opacity: 'hide' }, { duration: 300 }).promise().done(function() {
      $('#mx-new-foreign-key-link').show();
      controllMxTableSubmitCommandsDisplay();
    });
  };

  data.editingIndex = { id: mx.randomId(), columnIds: [], name: '', unique: false, condition: '', comment: '' };
  data.editingForeignKey = { id: mx.randomId(), ref_table_id: '', relations: [], comment: '' };
  data.refTableColumns = [];
  data.relationalIssues = [];
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
      },
      indexUnselectedColumnIds: function() {
        return mx.unselectedColumnIds(this.columns, this.editingIndex.columnIds);
      },
      foreignKeyUnselectedColumnIds: function() {
        var selectedColumnIds = mx.foreignKeyColumnIds(this.editingForeignKey);
        return mx.unselectedColumnIds(this.columns, selectedColumnIds);
      }
    },
    methods: {
      isSame: function(a, b) {
        return mx.isSame(a, b);
      },
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
        // editingIndex
        var editingIndexColumnIdIndex = $.inArray(column.$data.column.id.toString(), this.editingIndex.columnIds);
        if (editingIndexColumnIdIndex > -1) {
          this.editingIndex.columnIds.$remove(editingIndexColumnIdIndex);
        }
        // indices
        this.indices.forEach(function(index) {
          var idxIndex = $.inArray(column.$data.column.id.toString(), index.column_ids);
          if (idxIndex > -1) {
            index.column_ids.$remove(idxIndex);
          }
        });
        // editingForeignKey
        var editingForeignKeyColumnIds = mx.foreignKeyColumnIds(this.editingForeignKey);
        var editingForeignKeyColumnIdIndex = $.inArray(column.$data.column.id.toString(), editingForeignKeyColumnIds);
        if (editingForeignKeyColumnIdIndex > -1) {
          this.editingForeignKey.relations.$remove(editingForeignKeyColumnIdIndex);
        }
        // foreignKeys
        this.foreign_keys.forEach(function(foreignKey) {
          var foreignKeyColumnIds = mx.foreignKeyColumnIds(foreignKey);
          var foreignKeyColumnIdIndex = $.inArray(column.$data.column.id.toString(), foreignKeyColumnIds);
          if (foreignKeyColumnIdIndex > -1) {
            foreignKey.relations.$remove(foreignKeyColumnIdIndex);
          }
        });
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
      getPhysicalName: function(columnId) {
        var col = this.getColumn(columnId);
        return col ? col.physical_name : '';
      },
      getLogicalName: function(columnId) {
        var col = this.getColumn(columnId);
        return col ? col.logical_name : '';
      },
      getDataType: function(dataTypeId) {
        return mx.findById(this.data_types, dataTypeId);
      },
      changeColumnSet: function() {
        var baseColumnIds = $.map(this.columns, function(col) { return col.id.toString(); });
        // editingIndex
        for (var i = this.editingIndex.columnIds.length - 1; i >= 0; i--) {
          var columnId = this.editingIndex.columnIds[i].toString();
          if ($.inArray(columnId, baseColumnIds) === -1) {
            this.editingIndex.columnIds.$remove(i);
          }
        }
        // indices
        this.indices.forEach(function(index) {
          for (var i = index.column_ids.length - 1; i >= 0; i--) {
            var columnId = index.column_ids[i].toString();
            if ($.inArray(columnId, baseColumnIds) === -1) {
              index.column_ids.$remove(i);
            }
          }
        });
        // editingForeignKey
        var editingForeignKeyColumnIds = mx.foreignKeyColumnIds(this.editingForeignKey);
        for (var i = editingForeignKeyColumnIds.length - 1; i >= 0; i--) {
          var columnId = editingForeignKeyColumnIds[i].toString();
          if ($.inArray(columnId, baseColumnIds) === -1) {
            this.editingForeignKey.relations.$remove(i);
          }
        }
        // foreignKeys
        this.foreign_keys.forEach(function(foreignKey) {
          var foreignKeyColumnIds = mx.foreignKeyColumnIds(foreignKey);
          for (var i = foreignKeyColumnIds.length - 1; i >= 0; i--) {
            var columnId = foreignKeyColumnIds[i].toString();
            if ($.inArray(columnId, baseColumnIds) === -1) {
              foreignKey.relations.$remove(i);
            }
          }
        });
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
        mx.initEditingIndex(this.editingIndex);
        showMxIndexEdit();
      },
      editIndex: function(index) {
        this.editingIndex.id = index.$data.index.id;
        this.editingIndex.name = index.$data.index.name;
        this.editingIndex.columnIds = index.$data.index.column_ids;
        this.editingIndex.unique = index.$data.index.unique;
        this.editingIndex.condition = index.$data.index.condition;
        this.editingIndex.comment = index.$data.index.comment;
        showMxIndexEdit();
      },
      removeIndex: function(index) {
        this.indices.$remove(index.$index);
      },
      addToIndexColumns: function(columnId) {
        this.editingIndex.columnIds.push(columnId.$data.columnId);
      },
      removeFromIndexColumns: function(columnId) {
        this.editingIndex.columnIds.$remove(columnId.$index);
      },
      saveIndex: function() {
        hideMxIndexEdit();
        var savedIndexIds = $.map(this.indices, function(index) { return index.id.toString(); });
        var indexPosition = $.inArray(this.editingIndex.id.toString(), savedIndexIds);
        var indexData = {
          id: this.editingIndex.id,
          name: this.editingIndex.name,
          column_ids: this.editingIndex.columnIds,
          unique: this.editingIndex.unique,
          condition: this.editingIndex.condition,
          comment: this.editingIndex.comment
        };
        if (indexPosition > -1) {
          this.indices.$set(indexPosition, indexData);
        } else {
          this.indices.push(indexData);
        }
        mx.initEditingIndex(this.editingIndex);
      },
      cancelIndexEditing: function() {
        hideMxIndexEdit();
        mx.initEditingIndex(this.editingIndex);
      },
      enumColumnNames: function(columnIds) {
        if (!columnIds) {
          return '';
        }
        var cols = this.columns;
        var physicalNames = $.map(columnIds, function(columnId) {
          var col = mx.findById(cols, columnId);
          return col ? col.physical_name : '';
        });
        return physicalNames.join(', ');
      },
      loadRefTableColumns: function() {
        var refTableId = $('#ref-table').val();
        if (refTableId === '') {
          this.refTableColumns = [];
          return false;
        }
        var editingRelations = this.editingForeignKey.relations;
        mx.loadRefTableColumns(this, refTableId, function() {
          editingRelations.forEach(function(rel) {
            rel.ref_column_id = null;
          });
        });
      },
      newForeignKey: function() {
        mx.initEditingForeignKey(this);
        showMxForeignKeyEdit();
      },
      editForeignKey: function(foreignKey) {
        var editingFk = this.editingForeignKey;
        mx.loadRefTableColumns(this, foreignKey.$data.foreign_key.ref_table_id, function() {
          editingFk.id = foreignKey.$data.foreign_key.id;
          editingFk.name = foreignKey.$data.foreign_key.name;
          editingFk.ref_table_id = foreignKey.$data.foreign_key.ref_table_id;
          editingFk.relations = foreignKey.$data.foreign_key.relations;
          editingFk.comment = foreignKey.$data.foreign_key.comment;
          showMxForeignKeyEdit();
        });
      },
      addToForeignKeyRelations: function(columnId) {
        this.editingForeignKey.relations.push({ id: mx.randomId(), column_id: columnId.$data.columnId, ref_column_id: '' });
      },
      removeFromForeignKeyRelations: function(relation) {
        this.editingForeignKey.relations.$remove(relation.$index);
      },
      saveForeignKey: function() {
        hideMxForeignKeyEdit();
        var savedForeignKeyIds = $.map(this.foreign_keys, function(foreignKey) { return foreignKey.id.toString(); });
        var foreignKeyPosition = $.inArray(this.editingForeignKey.id.toString(), savedForeignKeyIds);
        var foreignKeyData = {
          id: this.editingForeignKey.id,
          name: this.editingForeignKey.name,
          ref_table_id: this.editingForeignKey.ref_table_id,
          ref_table_name: $('#ref-table option:selected').text(),
          comment: this.editingForeignKey.comment
        };
        foreignKeyData.relations = [];
        var refTableCols = this.refTableColumns;
        this.editingForeignKey.relations.forEach(function(relation) {
          var refColumnName = '';
          refTableCols.forEach(function(refTableColumn) {
            if (refTableColumn.id.toString() === relation.ref_column_id.toString()) {
              refColumnName = refTableColumn.physical_name;
            }
          });
          foreignKeyData.relations.push({ id: relation.id, column_id: relation.column_id, ref_column_id: relation.ref_column_id, ref_column_name: refColumnName });
        });
        if (foreignKeyPosition > -1) {
          this.foreign_keys.$set(foreignKeyPosition, foreignKeyData);
        } else {
          this.foreign_keys.push(foreignKeyData);
        }
        mx.initEditingForeignKey(this);
      },
      cancelForeignKeyEditing: function() {
        mx.initEditingForeignKey(this);
        hideMxForeignKeyEdit();
      },
      removeForeignKey: function(foreignKey) {
        this.foreign_keys.$remove(foreignKey.$index);
      },
      enumForeignKeyColumnNames: function(foreignKey) {
        return this.enumColumnNames(mx.foreignKeyColumnIds(foreignKey));
      },
      enumRefColumnNames: function(foreignKey) {
        var refColumnNames = $.map(foreignKey.relations, function(relation) { return relation.ref_column_name; });
        return refColumnNames.join(', ');
      },
      addRelationalIssue: function() {
        var issueId = $('#mx_relational_issue_id').val();
        var vueModel = this;
        var relatedIssue = mx.findById(vueModel.relationalIssues, issueId);
        if (issueId && !relatedIssue) {
          $.ajax({
            type: 'GET',
            url: '/issues/' + issueId + '.json'
          }).done(function(res) {
            var issue = res.issue;
            vueModel.relationalIssues.push( { id: issue.id, tracker: issue.tracker.name, subject: issue.subject });
          });
        }
      }
    }
  });
}

$(function() {
  $(document).on("keypress", "input:not(.mx-allow-submit)", function(event) {
    return event.which !== 13;
  });
});
