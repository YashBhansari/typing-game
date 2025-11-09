package com.typinggame.servlet;

import com.typinggame.dao.UserDAO;
import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

import java.io.IOException;

@WebServlet("/AuthServlet")
public class AuthServlet extends HttpServlet
{
	private static final long serialVersionUID = 1L;

	protected void do_post(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException
    {
        String action = request.getParameter("action");

		if ("register".equals(action)) {
			String username = request.getParameter("username");
			String email = request.getParameter("email");
			String password = request.getParameter("password");

			try {
				boolean success = UserDAO.register_user(username, email, password);
				if (success) {
					response.sendRedirect("login.jsp");
				} else {
					System.out.println("❌ Registration failed: UserDAO returned false");
					response.sendRedirect("register.jsp?error=1");
				}
			} catch (Exception e) {
				e.printStackTrace(); // Prints the SQL cause in Eclipse console
				response.sendRedirect("register.jsp?error=db");
			}
		}
        else if ("login".equals(action))
        {
            String email = request.getParameter("email");
            String password = request.getParameter("password");
            

            boolean valid = UserDAO.validate_user(email, password);
            if (valid)
            {
				HttpSession session = request.getSession();
				session.setAttribute("email", email);
                String username = UserDAO.get_username_by_email(email);
                session.setAttribute("username", username);
                response.sendRedirect("home.jsp");
            }
            else
            {
                response.sendRedirect("login.jsp?error=1");
            }
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException
    {
        do_post(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException
    {
        do_post(request, response);
    }
}
