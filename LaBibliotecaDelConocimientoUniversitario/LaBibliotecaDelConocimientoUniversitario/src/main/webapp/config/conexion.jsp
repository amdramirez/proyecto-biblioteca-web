<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.sql.*" %>
<%!
    // Configuración de la base de datos
    private static final String DB_URL = "jdbc:mysql://localhost:3306/biblioteca";
    private static final String DB_USER = "root";
    private static final String DB_PASS = "";
    
    // Método para obtener conexión
    public static Connection getConnection() throws Exception {
        Class.forName("com.mysql.cj.jdbc.Driver");
        return DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);
    }
    
    // Método para cerrar recursos
    public static void closeResources(Connection conn, PreparedStatement pstmt, ResultSet rs) {
        try {
            if (rs != null) rs.close();
            if (pstmt != null) pstmt.close();
            if (conn != null) conn.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
    
    // Método para verificar sesión
    public static boolean isValidSession(HttpSession session) {
        return session != null && session.getAttribute("usuario_id") != null;
    }
    
    // Método para verificar tipo de usuario
    public static boolean isUserType(HttpSession session, String expectedType) {
        if (!isValidSession(session)) return false;
        String userType = (String) session.getAttribute("tipo_usuario");
        return expectedType.equals(userType);
    }
%>
