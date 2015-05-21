import java.sql.*;

class Sites {
	public Sites() {
	}
	public String getSite(int i){
		
		String s = "huh";
		Connection con;
		Statement stmt;
		String sqlcmd = "SELECT site_name, site_id FROM site where site_id="+i;

		try {
			Class.forName("sun.jdbc.odbc.JdbcOdbcDriver");
		} catch (java.lang.ClassNotFoundException e) {
			System.err.print("ClassNotFoundException: ");
			System.err.println(e.getMessage());
		}

		try {
			con = DriverManager.getConnection("jdbc:odbc:rocky_lter_climdb","climdb", "adm4cdb*");
            stmt = con.createStatement();
			ResultSet rs = stmt.executeQuery(sqlcmd);
		
			while (rs.next()) {
				s = rs.getString("site_name");
			}
		
            stmt.close();
            con.close();

        } catch(SQLException ex) {
            s ="SQLException: " + ex.getMessage();
        }
			
	return (s);
	}
}
		
		
		
		
		
