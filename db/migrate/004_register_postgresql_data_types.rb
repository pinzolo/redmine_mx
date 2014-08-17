class RegisterPostgresqlDataTypes < ActiveRecord::Migration
  NAME = 'PostgreSQL'

  def up
    data_types = [
      { name: 'smallint'                , sizable: false, scalable: false },
      { name: 'integer'                 , sizable: false, scalable: false },
      { name: 'bigint'                  , sizable: false, scalable: false },
      { name: 'decimal'                 , sizable: true , scalable: true  },
      { name: 'numeric'                 , sizable: true , scalable: true  },
      { name: 'real'                    , sizable: false, scalable: false },
      { name: 'double precision'        , sizable: false, scalable: false },
      { name: 'serial'                  , sizable: false, scalable: false },
      { name: 'bigserial'               , sizable: false, scalable: false },
      { name: 'money'                   , sizable: false, scalable: false },
      { name: 'char'                    , sizable: true , scalable: false },
      { name: 'varchar'                 , sizable: true , scalable: false },
      { name: 'text'                    , sizable: false, scalable: false },
      { name: 'bytea'                   , sizable: false, scalable: false },
      { name: 'timestamp'               , sizable: true , scalable: false },
      { name: 'timestamp with time zone', sizable: true , scalable: false },
      { name: 'date'                    , sizable: false, scalable: false },
      { name: 'time'                    , sizable: true , scalable: false },
      { name: 'time with time zone'     , sizable: true , scalable: false },
      { name: 'interval'                , sizable: true , scalable: false },
      { name: 'boolean'                 , sizable: false, scalable: false }
    ]
    ActiveRecord::Base.transaction do
      db = MxDbms::Postgresql.create!(name: NAME, comment: "Builtin DBMS as #{NAME} type")
      data_types.each do |data_type|
        MxDataType.create!(data_type.merge(dbms_product_id: db.id))
      end
    end
  end

  def down
    MxDbms::Postgresql.where(name: NAME).first.try(:destroy)
  end
end

