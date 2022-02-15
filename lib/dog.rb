class Dog
    attr_accessor :name, :breed, :id

    @@all = []

    def initialize(name:, breed:, id: nil )
        @name = name
        @breed = breed
        @id = id
        @@all << self
    end

    def self.create_table
        sql =  <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      )
      SQL
    DB[:conn].execute(sql)

    end

    def self.drop_table
        sql = <<-SQL
        DROP TABLE dogs
        SQL
    DB[:conn].execute(sql)

    end

    def save
        sql = <<-SQL
          INSERT INTO dogs (name, breed)
          VALUES (?, ?)
        SQL
    
        # insert the dog
        DB[:conn].execute(sql, self.name, self.breed)
    
        # get the dog ID from the database and save it to the Ruby instance
        self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    
        # return the Ruby instance
        self
      end

      def self.create(name:, breed:)
        dog = Dog.new(name: name, breed: breed)
        dog.save
      end

      def self.new_from_db(row)
        self.new(name: row[1], breed: row[2], id: row[0])
      end

      def self.all
        sql = <<-SQL
        SELECT * FROM dogs;
        SQL
        test = DB[:conn].execute(sql)
        test.map do |t| 
            self.new_from_db(t)
        end 
      end

      def self.find_by_name(name)
        sql = <<-SQL
        SELECT * FROM dogs WHERE name= ? LIMIT 1
        SQL
        DB[:conn].execute(sql, name).map do |row|
            self.new_from_db(row)
        end.first
      end

      def self.find(id)
        sql = <<-SQL
        SELECT * FROM dogs WHERE id= ? LIMIT 1
        SQL
        DB[:conn].execute(sql, id).map do |row|
            self.new_from_db(row)
        end.first
      end

      def self.find_or_create_by(name:, breed:)
        
        sql = <<-SQL
        SELECT * FROM dogs WHERE (name= ? AND breed= ?) LIMIT 1
        SQL
        result= DB[:conn].execute(sql, name, breed).map do |row|
            self.new_from_db(row)
        end.first
        if result.nil?
          self.create(name: name, breed: breed)
        else 
          return result
        end
      end

      def update(name)
        sql = <<-SQL
        UPDATE dogs SET name = #{name};
        SQL
        DB[:conn].execute(sql)

      end


end
