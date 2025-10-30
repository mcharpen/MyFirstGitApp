package app.youtube;

import jakarta.persistence.*;
import java.math.BigDecimal;

@Entity
@Table(name = "emp")
public class Emp {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    public Long id;

    @Column(name = "first_name")
    public String firstName;

    @Column(name = "last_name")
    public String lastName;

    @Column(name = "birth_date")
    public java.sql.Date birthDate;

    @Column(name = "salary")
    public BigDecimal salary;

    protected Emp() { }
}
