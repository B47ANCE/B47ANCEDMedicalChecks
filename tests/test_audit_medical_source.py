"""Optional evidence-tool tests: Python/Jawa fixtures, never native runtime proof."""
import io
from pathlib import Path
import sys
import unittest

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / 'scripts'))
from audit_medical_source import disassemble
from jawa.cf import ClassFile


def fixture():
    cf = ClassFile.create('EvidenceFixture')
    cf.access_flags.acc_abstract = True
    for descriptor in ['()V', '(I)V']:
        method = cf.methods.create('present', descriptor)
        method.access_flags.acc_abstract = True
    data = io.BytesIO()
    cf.save(data)
    return data.getvalue()


class EvidenceSelectors(unittest.TestCase):
    def test_missing_selected_method_rejects_incomplete_evidence(self):
        with self.assertRaisesRegex(ValueError, 'absent'):
            disassemble(fixture(), ['present', 'absent'])

    def test_all_overloads_of_existing_selector_are_retained(self):
        text = disassemble(fixture(), ['present'])
        self.assertIn('METHOD present()V', text)
        self.assertIn('METHOD present(I)V', text)


if __name__ == '__main__':
    unittest.main()
