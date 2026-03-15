package com.typinggame.servlet;

import com.typinggame.dao.UserDAO;
import javax.servlet.*;
import javax.servlet.http.*;
import java.io.IOException;

public class AuthServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");

        if ("register".equals(action)) {
            String username = request.getParameter("username");
            String email    = request.getParameter("email");
            String password = request.getParameter("password");

            // Basic server-side validation
            if (username == null || username.trim().isEmpty() ||
                email == null || email.trim().isEmpty() ||
                password == null || password.length() < 6) {
                request.setAttribute("error", "All fields are required and password must be at least 6 characters.");
                request.getRequestDispatcher("register.jsp").forward(request, response);
                return;
            }

            boolean success = UserDAO.register_user(username.trim(), email.trim(), password);
            if (success) {
                request.setAttribute("message", "Registration successful! Please log in.");
                request.getRequestDispatcher("login.jsp").forward(request, response);
            } else {
                request.setAttribute("error", "Username or email is already taken. Please try another.");
                request.getRequestDispatcher("register.jsp").forward(request, response);
            }

        } else if ("login".equals(action)) {
            String email    = request.getParameter("email");
            String password = request.getParameter("password");

            if (email == null || email.trim().isEmpty() || password == null || password.isEmpty()) {
                request.setAttribute("error", "Email and password are required.");
                request.getRequestDispatcher("login.jsp").forward(request, response);
                return;
            }

            boolean valid = UserDAO.validate_user(email.trim(), password);
            if (valid) {
                HttpSession session = request.getSession(true);
                session.setAttribute("email", email.trim().toLowerCase());
                String username = UserDAO.get_username_by_email(email.trim());
                Integer userId  = UserDAO.get_user_id_by_email(email.trim());
                session.setAttribute("username", username);
                session.setAttribute("user_id", userId);
                session.setMaxInactiveInterval(60 * 60); // 1 hour
                response.sendRedirect("home.jsp");
            } else {
                request.setAttribute("error", "Invalid email or password.");
                request.getRequestDispatcher("login.jsp").forward(request, response);
            }

        } else {
            response.sendRedirect("login.jsp");
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect("login.jsp");
    }
}
