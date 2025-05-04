package uz.learn.raceconditionspgex;

import org.springframework.data.annotation.Id;
import org.springframework.data.relational.core.mapping.Column;
import org.springframework.data.relational.core.mapping.Table;

import java.math.BigDecimal;

@Table("hold")
public record Hold(
    @Id 
    @Column("external_id")
    String externalId,
    BigDecimal amount,
    String status
) {}
