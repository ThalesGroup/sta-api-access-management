using System.ComponentModel.DataAnnotations;
using System.Linq;
using Microsoft.AspNetCore.Mvc.Controllers;
using Microsoft.OpenApi.Models;
using Swashbuckle.AspNetCore.SwaggerGen;

namespace Store.Filters
{
    /// <summary>
    /// Path Parameter Validation Rules Filter
    /// </summary>
    // ReSharper disable once ClassNeverInstantiated.Global
    public class GeneratePathParamsValidationFilter : IOperationFilter
    {
        /// <summary>
        /// Constructor
        /// </summary>
        /// <param name="operation">Operation</param>
        /// <param name="context">OperationFilterContext</param>
        public void Apply(OpenApiOperation operation, OperationFilterContext context)
        {
            var pars = context.ApiDescription.ParameterDescriptions;

            foreach (var par in pars)
            {
                var swaggerParam = operation.Parameters.SingleOrDefault(p => p.Name == par.Name);

                var attributes = ((ControllerParameterDescriptor)par.ParameterDescriptor).ParameterInfo.CustomAttributes;

                var customAttributeData = attributes.ToList();
                if (!customAttributeData.Any() || swaggerParam == null) continue;
                {
                    // Required - [Required]
                    var requiredAttr = customAttributeData.FirstOrDefault(p => p.AttributeType == typeof(RequiredAttribute));
                    if (requiredAttr != null)
                    {
                        swaggerParam.Required = true;
                    }

                    // Regex Pattern [RegularExpression]
                    var regexAttr =
                        customAttributeData.FirstOrDefault(p => p.AttributeType == typeof(RegularExpressionAttribute));
                    if (regexAttr != null)
                    {
                        var regex = (string) regexAttr.ConstructorArguments[0].Value;
                        swaggerParam.Schema.Pattern = regex;
                    }

                    // String Length [StringLength]
                    int? minLenght = null, maxLength = null;
                    var stringLengthAttr =
                        customAttributeData.FirstOrDefault(p => p.AttributeType == typeof(StringLengthAttribute));
                    if (stringLengthAttr != null)
                    {
                        if (stringLengthAttr.NamedArguments?.Count == 1)
                        {
                            var typedValueValue = stringLengthAttr.NamedArguments
                                .Single(p => p.MemberName == "MinimumLength").TypedValue.Value;
                            if (typedValueValue != null)
                                minLenght = (int) typedValueValue;
                        }

                        var value = stringLengthAttr.ConstructorArguments[0].Value;
                        if (value != null)
                            maxLength = (int) value;
                    }

                    var minLengthAttr = customAttributeData.FirstOrDefault(p => p.AttributeType == typeof(MinLengthAttribute));
                    if (minLengthAttr != null)
                    {
                        var value = minLengthAttr.ConstructorArguments[0].Value;
                        if (value != null)
                            minLenght = (int) value;
                    }

                    var maxLengthAttr = customAttributeData.FirstOrDefault(p => p.AttributeType == typeof(MaxLengthAttribute));
                    if (maxLengthAttr != null)
                    {
                        var value = maxLengthAttr.ConstructorArguments[0].Value;
                        if (value != null)
                            maxLength = (int) value;
                    }

                    swaggerParam.Schema.MinLength = minLenght;
                    swaggerParam.Schema.MaxLength = maxLength;

                    // Range [Range]
                    var rangeAttr = customAttributeData.FirstOrDefault(p => p.AttributeType == typeof(RangeAttribute));
                    if (rangeAttr != null)
                    {
                        var rangeMin = (int?) rangeAttr.ConstructorArguments[0].Value;
                        var rangeMax = (int?) rangeAttr.ConstructorArguments[1].Value;

                        if (swaggerParam != null)
                        {
                            swaggerParam.Schema.Minimum = rangeMin;
                            swaggerParam.Schema.Maximum = rangeMax;
                        }
                    }
                }
            }
        }
    }
}
