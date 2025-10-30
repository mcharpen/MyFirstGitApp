package app.youtube;

import jakarta.inject.Inject;
import jakarta.transaction.Transactional;
import jakarta.ws.rs.*;
import jakarta.ws.rs.core.MediaType;
import jakarta.persistence.*;
import jakarta.enterprise.context.ApplicationScoped;
import java.util.List;
import java.math.BigDecimal;

@Path("/emp")
@ApplicationScoped
@Produces(MediaType.APPLICATION_JSON)
@Consumes(MediaType.APPLICATION_JSON)
public class EmpResource {
    @Inject
    EntityManager em;

    @GET
    public List<Emp> getAll() {
        return em.createQuery("SELECT e FROM Emp e", Emp.class).getResultList();
    }

    @POST
    @Transactional
    public Emp create(EmpDto dto) {
        if (dto.firstName == null || dto.firstName.isBlank() || dto.lastName == null || dto.lastName.isBlank()) {
            throw new WebApplicationException("First name and last name are required.", 400);
        }
        Emp emp = new Emp();
        emp.firstName = dto.firstName;
        emp.lastName = dto.lastName;
        try {
            emp.birthDate = dto.birthDate != null ? java.sql.Date.valueOf(dto.birthDate) : null;
        } catch (Exception ex) {
            throw new WebApplicationException("Invalid birth date.", 400);
        }
        emp.salary = (dto.salary != null && !dto.salary.isBlank()) ? new BigDecimal(dto.salary) : null;
        em.persist(emp);
        return emp;
    }

    public static class EmpDto {
        public String firstName;
        public String lastName;
        public String birthDate; // Expecting yyyy-mm-dd
        public String salary; // as string for compatibility
    }
}
